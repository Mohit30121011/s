package com.nlogistic.model;

import java.util.Date;

public class DemandForecast {
    private int forecastId;
    private String containerType;
    private int routeId;
    private String forecastPeriod;
    private double forecastedDemand;
    private double forecastedPrice;
    private String algorithmVersion;
    private java.util.Date generatedAt;

    public DemandForecast() {}

    public int getForecastId() {
        return forecastId;
    }

    public void setForecastId(int forecastId) {
        this.forecastId = forecastId;
    }

    public String getContainerType() {
        return containerType;
    }

    public void setContainerType(String containerType) {
        this.containerType = containerType;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public String getForecastPeriod() {
        return forecastPeriod;
    }

    public void setForecastPeriod(String forecastPeriod) {
        this.forecastPeriod = forecastPeriod;
    }

    public double getForecastedDemand() {
        return forecastedDemand;
    }

    public void setForecastedDemand(double forecastedDemand) {
        this.forecastedDemand = forecastedDemand;
    }

    public double getForecastedPrice() {
        return forecastedPrice;
    }

    public void setForecastedPrice(double forecastedPrice) {
        this.forecastedPrice = forecastedPrice;
    }

    public String getAlgorithmVersion() {
        return algorithmVersion;
    }

    public void setAlgorithmVersion(String algorithmVersion) {
        this.algorithmVersion = algorithmVersion;
    }

    public java.util.Date getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(java.util.Date generatedAt) {
        this.generatedAt = generatedAt;
    }

}
