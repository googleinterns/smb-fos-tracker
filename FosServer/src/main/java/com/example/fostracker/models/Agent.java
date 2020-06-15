package com.example.fostracker.models;

import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

public class Agent {
    Name name;
    String email;
    String phone;
    Coordinates coordinates;
    Timestamp agentCreationDateTime;

    public Agent(Name name, String email, String phone, Coordinates coordinates) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.coordinates = coordinates;
        this.agentCreationDateTime = Timestamp.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Kolkata")).toLocalDateTime());
    }

    public Name getAgentName() {
        return name;
    }

    public void setAgentName(Name name) {
        this.name = name;
    }

    public String getAgentEmail() {
        return email;
    }

    public void setAgentEmail(String email) {
        this.email = email;
    }

    public String getAgentPhone() {
        return phone;
    }

    public void setAgentPhone(String phone) {
        this.phone = phone;
    }

    public Coordinates getAgentCoordinates() {
        return coordinates;
    }

    public void setAgentCoordinates(Coordinates coordinates) {
        this.coordinates = coordinates;
    }

    public Timestamp getAgentCreationDateTime() {
        return agentCreationDateTime;
    }

    public void setAgentCreationDateTime(Timestamp agentCreationDateTime) {
        this.agentCreationDateTime = agentCreationDateTime;
    }
}