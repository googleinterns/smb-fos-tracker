package com.example.fostracker.models;

import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

public class Verification {
    String agentID;
    String storeID;
    Coordinates coordinates;
    String status;
    Timestamp creationDateTime;

    public Verification(String agentID, String storeID, Coordinates coordinates, String status) {
        this.agentID = agentID;
        this.storeID = storeID;
        this.coordinates = coordinates;
        this.status = status;
        this.creationDateTime = Timestamp.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Kolkata")).toLocalDateTime());
    }

    public String getAgentID() {
        return agentID;
    }

    public void setAgentID(String agentID) {
        this.agentID = agentID;
    }

    public String getStoreID() {
        return storeID;
    }

    public void setStoreID(String storeID) {
        this.storeID = storeID;
    }

    public Coordinates getVerificationCoordinates() {
        return coordinates;
    }

    public void setVerificationCoordinates(Coordinates coordinates) {
        this.coordinates = coordinates;
    }

    public String getStoreVerificationStatus() {
        return status;
    }

    public void setStoreVerificationStatus(String status) {
        this.status = status;
    }

    public Timestamp getStoreVerificationDateTime() {
        return creationDateTime;
    }
}