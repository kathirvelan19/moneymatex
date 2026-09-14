package com.monematex.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class OCRService {

    @Value("${ai.api.key:${GEMINI_API_KEY:}}")
    private String apiKey;

    @Value("${ai.model:gemini-2.0-flash}")
    private String modelName;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public Map<String, Object> scanReceipt(String imageDataUrl) {
        if (imageDataUrl == null || imageDataUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Image payload is required for OCR scanning.");
        }

        String mimeType = detectMimeType(imageDataUrl);
        String base64Data = extractBase64(imageDataUrl);

        if (apiKey == null || apiKey.trim().isEmpty()) {
            // Fallback response if API key is not configured yet
            return createFallbackResponse("Missing Gemini API Key. Please provide GEMINI_API_KEY environment variable.");
        }

        try {
            String promptText = """
                    You are an expert financial receipt, bill, and transport ticket OCR parser.
                    Analyze the provided image of a receipt, bill, or transport ticket.
                    Extract fields and return ONLY a raw JSON object with NO markdown code fences, NO backticks, and NO extra text.
                    JSON schema:
                    {
                      "merchant": "Vendor name (string)",
                      "amount": "Total amount numeric string without currency symbols (e.g. 150.00)",
                      "date": "Date YYYY-MM-DD (string)",
                      "category": "Food & Dining, Transport, Shopping, Bills & Utilities, Entertainment, or Other",
                      "payment_method": "Cash, UPI, Card, or Unknown",
                      "is_ticket": boolean,
                      "route_from": "string or null",
                      "route_to": "string or null",
                      "ticket_no": "string or null"
                    }
                    """;

            Map<String, Object> requestBody = Map.of(
                    "contents", List.of(
                            Map.of("parts", List.of(
                                    Map.of("text", promptText),
                                    Map.of("inline_data", Map.of(
                                            "mime_type", mimeType,
                                            "data", base64Data
                                    ))
                            ))
                    )
            );

            String urlStr = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + apiKey.trim();
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(20000);

            String jsonPayload = objectMapper.writeValueAsString(requestBody);
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            if (code == 200) {
                String responseStr = new String(conn.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
                Map<?, ?> respMap = objectMapper.readValue(responseStr, Map.class);
                List<?> candidates = (List<?>) respMap.get("candidates");
                if (candidates != null && !candidates.isEmpty()) {
                    Map<?, ?> firstCand = (Map<?, ?>) candidates.get(0);
                    Map<?, ?> content = (Map<?, ?>) firstCand.get("content");
                    List<?> parts = (List<?>) content.get("parts");
                    if (parts != null && !parts.isEmpty()) {
                        Map<?, ?> part = (Map<?, ?>) parts.get(0);
                        String rawText = (String) part.get("text");
                        return parseCleanJson(rawText);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[SPRING BOOT OCR ERROR] OCR processing failed: " + e.getMessage());
        }

        return createFallbackResponse("OCR processing could not parse receipt automatically.");
    }

    private Map<String, Object> parseCleanJson(String rawText) {
        try {
            String clean = rawText.trim();
            if (clean.startsWith("```")) {
                clean = clean.replaceAll("^```[a-zA-Z]*\n?", "").replaceAll("\n?```$", "").trim();
            }
            Map<String, Object> result = objectMapper.readValue(clean, Map.class);
            result.put("isSuccess", true);
            return result;
        } catch (Exception e) {
            return createFallbackResponse("Failed to parse receipt data.");
        }
    }

    private Map<String, Object> createFallbackResponse(String message) {
        Map<String, Object> fallback = new HashMap<>();
        fallback.put("isSuccess", false);
        fallback.put("errorMessage", message);
        fallback.put("merchant", "");
        fallback.put("amount", "");
        fallback.put("category", "Other");
        fallback.put("payment_method", "Unknown");
        return fallback;
    }

    private String extractBase64(String dataUrl) {
        if (!dataUrl.contains(",")) return dataUrl;
        return dataUrl.split(",")[1].trim();
    }

    private String detectMimeType(String dataUrl) {
        String lower = dataUrl.toLowerCase();
        if (lower.contains("image/png")) return "image/png";
        if (lower.contains("image/webp")) return "image/webp";
        return "image/jpeg";
    }
}
