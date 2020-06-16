package com.example.fostracker.models;

import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

/**
 * Serves as a model for agent objects that will be used in to communicate information about FOS Agents
 */
public class Agent {
    Name name;
    String email;
    String phone;
    Coordinates coordinates;
    Timestamp agentCreationDateTime;

    /**
     * @param name        - The agent's name
     * @param email       - the gmail address associated with the agent's account
     * @param phone       - The phone number associated with the agent's account
     * @param coordinates - The live coordinates of the agent at the time of creation. They can be updated later
     *                    agentCreationDateTime is set by default to the current time of Asia/Kolkata and cannot be changed later
     */
    public Agent(Name name, String email, String phone, Coordinates coordinates) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.coordinates = coordinates;
        this.agentCreationDateTime = Timestamp.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Kolkata")).toLocalDateTime());
    }

    /**
     * @param name                  - The agent's name
     * @param email                 - the gmail address associated with the agent's account
     * @param phone                 - The phone number associated with the agent's account
     * @param coordinates           - The live coordinates of the agent at the time of creation. They can be updated later
     * @param agentCreationDateTime is absolute time when agent had been created.
     */
    public Agent(Name name, String email, String phone, Coordinates coordinates, Timestamp agentCreationDateTime) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.coordinates = coordinates;
        this.agentCreationDateTime = agentCreationDateTime;
    }

    /**
     * @param email                 - the gmail address associated with the agent's account
     * @param coordinates           - The live coordinates of the agent at the time of creation. They can be updated later
     */
    public Agent( String email,Coordinates coordinates ) {
        this.email = email;
        this.coordinates = coordinates;
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