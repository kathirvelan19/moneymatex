package com.monematex.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.logging.Logger;

/**
 * OCRService — Receipt image extraction using Google Gemini API.
 *
 * Security contract:
 *  - GEMINI_API_KEY is loaded via Spring @Value from application.properties (gemini.api.key).
 *  - The key is NEVER logged, NEVER returned in API responses.
 *  - All Gemini calls are server-to-server (Spring Boot → Gemini).
 *  - The browser never receives or uses the API key.
 *
 * Centralized configuration:
 *  - Model: configured via gemini.model property (default: gemini-2.0-flash)
 *  - Prompt: defined once as RECEIPT_EXTRACTION_PROMPT constant
 *  - Response schema: enforced via generationConfig.responseSchema
 *
 * Parity guarantee:
 *  - Localhost and production use identical Java code, prompt, model, and schema.
 *  - The only environment-specific value is GEMINI_API_KEY (set via env var).
 */
@Service
public class OCRService {

    private static final Logger log = Logger.getLogger(OCRService.class.getName());

    // ── Centralized Gemini Prompt ─────────────────────────────────────────────
    // This is the SINGLE authoritative prompt used in both local and production.
    // Do NOT duplicate this prompt in any other file.
    private static final String RECEIPT_EXTRACTION_PROMPT =
            "Extract receipt data into JSON: merchant name, date (YYYY-MM-DD), " +
            "total amount (number only, no currency symbols), currency symbol, " +
            "payment method (Cash/UPI/Card/Unknown), category " +
            "(Food & Dining/Transport/Shopping/Bills & Utilities/Entertainment/Other), " +
            "is_ticket (boolean), route_from (string or null), route_to (string or null), ticket_no (string or null). " +
            "Return only valid JSON. No markdown, no backticks, no extra text.";

    // ── API Key ───────────────────────────────────────────────────────────────
    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    // ── Model ─────────────────────────────────────────────────────────────────
    @Value("${gemini.model:gemini-2.0-flash}")
    private String geminiModel;

    // ── Debug mode ────────────────────────────────────────────────────────────
    @Value("${ocr.debug:false}")
    private boolean ocrDebug;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // ── Startup validation ────────────────────────────────────────────────────
    @PostConstruct
    public void validateConfiguration() {
        if (geminiApiKey == null || geminiApiKey.isBlank()) {
            log.severe("[OCR CONFIG ERROR] GEMINI_API_KEY environment variable is not set. " +
                       "Receipt extraction will fail until this is configured in Render (production) " +
                       "or your local environment. Do NOT hardcode the key.");
        } else {
            log.info("[OCR CONFIG] Gemini API key is configured. Model: " + geminiModel);
        }
    }

    // ── isConfigured helper for health check ─────────────────────────────────
    public boolean isGeminiConfigured() {
        return geminiApiKey != null && !geminiApiKey.isBlank();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // scanReceipt — main entry point
    // Accepts a base64 data URL (data:image/jpeg;base64,...)
    // or raw base64 string.
    // ─────────────────────────────────────────────────────────────────────────
    public Map<String, Object> scanReceipt(String imageDataUrl) {
        String requestId = UUID.randomUUID().toString().substring(0, 8);

        if (imageDataUrl == null || imageDataUrl.isBlank()) {
            log.warning("[OCR:" + requestId + "] Rejected: empty image payload.");
            return errorResponse("Image payload is required for OCR scanning.", requestId);
        }

        if (!isGeminiConfigured()) {
            log.severe("[OCR:" + requestId + "] Rejected: GEMINI_API_KEY is not configured.");
            return errorResponse("Receipt extraction service is not configured. Please contact support.", requestId);
        }

        String mimeType = detectMimeType(imageDataUrl);
        if (mimeType == null) {
            log.warning("[OCR:" + requestId + "] Rejected: unsupported image format.");
            return errorResponse("Unsupported image format. Please upload JPEG, PNG, or WebP.", requestId);
        }

        String base64Data = extractBase64(imageDataUrl);
        if (base64Data == null || base64Data.isBlank()) {
            log.warning("[OCR:" + requestId + "] Rejected: could not extract base64 data from image.");
            return errorResponse("Invalid image encoding. Please re-upload the receipt.", requestId);
        }

        int imageSizeKb = (base64Data.length() * 3 / 4) / 1024;

        if (ocrDebug) {
            log.info(String.format("[OCR:%s][DEBUG] MIME=%s | ImageSize≈%dKB | Model=%s",
                    requestId, mimeType, imageSizeKb, geminiModel));
        } else {
            log.info(String.format("[OCR:%s] Processing receipt. MIME=%s | Size≈%dKB | Model=%s",
                    requestId, mimeType, imageSizeKb, geminiModel));
        }

        long startMs = System.currentTimeMillis();

        try {
            Map<String, Object> result = callGeminiForReceipt(requestId, base64Data, mimeType);
            long durationMs = System.currentTimeMillis() - startMs;
            log.info(String.format("[OCR:%s] Extraction completed in %dms. Success=%s",
                    requestId, durationMs, result.get("isSuccess")));
            result.put("requestId", requestId);
            return result;

        } catch (GeminiApiException e) {
            long durationMs = System.currentTimeMillis() - startMs;
            log.warning(String.format("[OCR:%s] Gemini API error after %dms: %s",
                    requestId, durationMs, e.getMessage()));
            return errorResponse("Receipt extraction service is temporarily unavailable. Please try again.", requestId);

        } catch (Exception e) {
            long durationMs = System.currentTimeMillis() - startMs;
            log.severe(String.format("[OCR:%s] Unexpected error after %dms: %s",
                    requestId, durationMs, e.getClass().getSimpleName() + ": " + e.getMessage()));
            return errorResponse("An unexpected error occurred during receipt processing.", requestId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // callGeminiForReceipt — builds and sends Gemini API request
    // Uses responseSchema for structured, predictable JSON output.
    // ─────────────────────────────────────────────────────────────────────────
    private Map<String, Object> callGeminiForReceipt(String requestId, String base64Data, String mimeType)
            throws GeminiApiException {

        // Build request body matching @google/genai SDK methodology:
        // - image part first, then text prompt
        // - generationConfig with responseMimeType + responseSchema
        Map<String, Object> inlineData = Map.of(
                "mime_type", mimeType,
                "data", base64Data
        );
        Map<String, Object> imagePart = Map.of("inline_data", inlineData);
        Map<String, Object> textPart  = Map.of("text", RECEIPT_EXTRACTION_PROMPT);

        Map<String, Object> content = new LinkedHashMap<>();
        content.put("parts", List.of(imagePart, textPart));

        // Response schema — forces Gemini to return typed structured JSON
        Map<String, Object> properties = new LinkedHashMap<>();
        properties.put("merchant",        Map.of("type", "STRING"));
        properties.put("amount",          Map.of("type", "STRING"));
        properties.put("date",            Map.of("type", "STRING"));
        properties.put("currency",        Map.of("type", "STRING", "nullable", true));
        properties.put("payment_method",  Map.of("type", "STRING"));
        properties.put("category",        Map.of("type", "STRING"));
        properties.put("is_ticket",       Map.of("type", "BOOLEAN"));
        properties.put("route_from",      Map.of("type", "STRING", "nullable", true));
        properties.put("route_to",        Map.of("type", "STRING", "nullable", true));
        properties.put("ticket_no",       Map.of("type", "STRING", "nullable", true));

        Map<String, Object> responseSchema = new LinkedHashMap<>();
        responseSchema.put("type", "OBJECT");
        responseSchema.put("properties", properties);
        responseSchema.put("required", List.of("merchant", "amount", "date", "payment_method", "category", "is_ticket"));

        Map<String, Object> generationConfig = new LinkedHashMap<>();
        generationConfig.put("responseMimeType", "application/json");
        generationConfig.put("responseSchema", responseSchema);

        Map<String, Object> requestBody = new LinkedHashMap<>();
        requestBody.put("contents", List.of(content));
        requestBody.put("generationConfig", generationConfig);

        String urlStr = "https://generativelanguage.googleapis.com/v1beta/models/"
                + geminiModel + ":generateContent?key=" + geminiApiKey.trim();

        try {
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(15_000);
            conn.setReadTimeout(25_000);

            String jsonPayload = objectMapper.writeValueAsString(requestBody);

            if (ocrDebug) {
                log.info("[OCR:" + requestId + "][DEBUG] Sending request to Gemini. Payload length: " + jsonPayload.length());
            }

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
            }

            int httpCode = conn.getResponseCode();

            if (ocrDebug) {
                log.info("[OCR:" + requestId + "][DEBUG] Gemini HTTP status: " + httpCode);
            }

            if (httpCode == 200) {
                String responseStr = new String(conn.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
                return parseGeminiResponse(requestId, responseStr);

            } else if (httpCode == 401 || httpCode == 403) {
                String errorBody = new String(conn.getErrorStream().readAllBytes(), StandardCharsets.UTF_8);
                log.severe("[OCR:" + requestId + "] Gemini authentication failed (HTTP " + httpCode + "). Check GEMINI_API_KEY on Render.");
                throw new GeminiApiException("Gemini authentication failed. Invalid or missing API key.");

            } else if (httpCode == 429) {
                log.warning("[OCR:" + requestId + "] Gemini rate limit exceeded (HTTP 429).");
                throw new GeminiApiException("Gemini rate limit exceeded. Please try again shortly.");

            } else if (httpCode == 400) {
                String errorBody = new String(conn.getErrorStream().readAllBytes(), StandardCharsets.UTF_8);
                log.warning("[OCR:" + requestId + "] Gemini bad request (HTTP 400): " + errorBody);
                throw new GeminiApiException("Gemini rejected the request. Image may be unsupported or corrupt.");

            } else {
                String errorBody = "";
                try { errorBody = new String(conn.getErrorStream().readAllBytes(), StandardCharsets.UTF_8); } catch (Exception ignored) {}
                log.warning("[OCR:" + requestId + "] Gemini error HTTP " + httpCode + ": " + errorBody);
                throw new GeminiApiException("Gemini returned error HTTP " + httpCode + ".");
            }

        } catch (GeminiApiException e) {
            throw e;
        } catch (java.net.SocketTimeoutException e) {
            throw new GeminiApiException("Gemini request timed out. Image may be too large or service unavailable.");
        } catch (Exception e) {
            throw new GeminiApiException("Failed to connect to Gemini: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // parseGeminiResponse — extracts and validates structured JSON from response
    // ─────────────────────────────────────────────────────────────────────────
    @SuppressWarnings("unchecked")
    private Map<String, Object> parseGeminiResponse(String requestId, String responseStr) throws GeminiApiException {
        try {
            Map<?, ?> respMap   = objectMapper.readValue(responseStr, Map.class);
            List<?>   candidates = (List<?>) respMap.get("candidates");

            if (candidates == null || candidates.isEmpty()) {
                throw new GeminiApiException("Gemini returned no candidates in response.");
            }

            Map<?, ?> firstCand    = (Map<?, ?>) candidates.get(0);
            Map<?, ?> contentObj   = (Map<?, ?>) firstCand.get("content");
            List<?>   parts        = (List<?>) contentObj.get("parts");

            if (parts == null || parts.isEmpty()) {
                throw new GeminiApiException("Gemini response contained no parts.");
            }

            String rawText = (String) ((Map<?, ?>) parts.get(0)).get("text");

            if (rawText == null || rawText.isBlank()) {
                throw new GeminiApiException("Gemini returned empty text.");
            }

            if (ocrDebug) {
                log.info("[OCR:" + requestId + "][DEBUG] Gemini raw text length: " + rawText.length());
            }

            return parseCleanJson(requestId, rawText);

        } catch (GeminiApiException e) {
            throw e;
        } catch (Exception e) {
            throw new GeminiApiException("Failed to parse Gemini response structure: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // parseCleanJson — strips markdown fences, decodes JSON, validates fields
    // ─────────────────────────────────────────────────────────────────────────
    @SuppressWarnings("unchecked")
    private Map<String, Object> parseCleanJson(String requestId, String rawText) throws GeminiApiException {
        try {
            String clean = rawText.trim();

            // Strip markdown fences if present (```json ... ```)
            if (clean.startsWith("```")) {
                clean = clean.replaceAll("(?s)^```[a-zA-Z]*\\s*", "").replaceAll("\\s*```$", "").trim();
            }

            // Find JSON object boundaries
            int firstBrace = clean.indexOf('{');
            int lastBrace  = clean.lastIndexOf('}');
            if (firstBrace >= 0 && lastBrace > firstBrace) {
                clean = clean.substring(firstBrace, lastBrace + 1);
            }

            Map<String, Object> result = (Map<String, Object>) objectMapper.readValue(clean, Map.class);

            // Validate required fields
            if (!result.containsKey("merchant") || !result.containsKey("amount")) {
                log.warning("[OCR:" + requestId + "] Gemini response missing required fields. Raw: " + rawText.substring(0, Math.min(200, rawText.length())));
                throw new GeminiApiException("Gemini response missing required receipt fields.");
            }

            result.put("isSuccess", true);
            return result;

        } catch (GeminiApiException e) {
            throw e;
        } catch (Exception e) {
            log.warning("[OCR:" + requestId + "] JSON parse failed: " + e.getMessage());
            throw new GeminiApiException("Could not parse Gemini JSON response: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Detects MIME type from data URL prefix.
     * Returns null for unsupported formats.
     */
    private String detectMimeType(String dataUrl) {
        if (dataUrl == null) return null;
        String lower = dataUrl.toLowerCase();
        if (lower.contains("image/jpeg") || lower.contains("image/jpg")) return "image/jpeg";
        if (lower.contains("image/png"))  return "image/png";
        if (lower.contains("image/webp")) return "image/webp";
        // Raw base64 without data URL prefix — assume JPEG
        if (!dataUrl.startsWith("data:")) return "image/jpeg";
        return null; // Unsupported format
    }

    /**
     * Extracts raw base64 string from data URL.
     * Handles both "data:image/jpeg;base64,..." and raw base64.
     */
    private String extractBase64(String dataUrl) {
        if (dataUrl == null) return null;
        if (dataUrl.contains(",")) {
            return dataUrl.substring(dataUrl.indexOf(',') + 1).trim();
        }
        return dataUrl.trim();
    }

    private Map<String, Object> errorResponse(String safeMessage, String requestId) {
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("isSuccess",    false);
        resp.put("errorMessage", safeMessage);
        resp.put("requestId",    requestId);
        resp.put("merchant",     "");
        resp.put("amount",       "");
        resp.put("category",     "Other");
        resp.put("payment_method", "Unknown");
        return resp;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Custom exception — keeps error handling clear
    // ─────────────────────────────────────────────────────────────────────────
    private static class GeminiApiException extends Exception {
        GeminiApiException(String message) { super(message); }
    }
}
