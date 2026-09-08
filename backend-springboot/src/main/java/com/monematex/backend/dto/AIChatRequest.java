package com.monematex.backend.dto;

public class AIChatRequest {
    private String prompt;

    public AIChatRequest() {}

    public AIChatRequest(String prompt) {
        this.prompt = prompt;
    }

    public String getPrompt() { return prompt; }
    public void setPrompt(String prompt) { this.prompt = prompt; }
}
