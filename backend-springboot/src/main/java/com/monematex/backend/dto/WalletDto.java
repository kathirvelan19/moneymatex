package com.monematex.backend.dto;

public class WalletDto {
    private String id;
    private String name;
    private String type;
    private String provider;
    private Double balance;
    private Boolean isPrimary;
    private String trackingMethod;
    private String createdAt;

    public WalletDto() {}

    public WalletDto(String id, String name, String type, String provider, Double balance,
                     Boolean isPrimary, String trackingMethod, String createdAt) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.provider = provider;
        this.balance = balance;
        this.isPrimary = isPrimary;
        this.trackingMethod = trackingMethod;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }

    public Double getBalance() { return balance; }
    public void setBalance(Double balance) { this.balance = balance; }

    public Boolean getIsPrimary() { return isPrimary; }
    public void setIsPrimary(Boolean isPrimary) { this.isPrimary = isPrimary; }

    public String getTrackingMethod() { return trackingMethod; }
    public void setTrackingMethod(String trackingMethod) { this.trackingMethod = trackingMethod; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
