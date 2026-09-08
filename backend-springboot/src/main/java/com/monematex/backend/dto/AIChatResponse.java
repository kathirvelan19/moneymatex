package com.monematex.backend.dto;

import java.util.Map;

public class AIChatResponse {
    private String response;
    private Map<String, Object> context;

    public AIChatResponse() {}

    public AIChatResponse(String response, Map<String, Object> context) {
        this.response = response;
        this.context = context;
    }

    public String getResponse() { return response; }
    public void setResponse(String response) { this.response = response; }

    public Map<String, Object> getContext() { return context; }
    public void setContext(Map<String, Object> context) { this.context = context; }
}
