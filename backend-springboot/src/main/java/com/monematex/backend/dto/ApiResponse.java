package com.monematex.backend.dto;

public class ApiResponse {
    private boolean success;
    private String message;
    private String resetToken;
    private String error;

    public ApiResponse() {}

    public ApiResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public ApiResponse(boolean success, String message, String resetToken) {
        this.success = success;
        this.message = message;
        this.resetToken = resetToken;
    }

    public static ApiResponse error(String error) {
        ApiResponse resp = new ApiResponse(false, null);
        resp.setError(error);
        return resp;
    }

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }

    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
}
