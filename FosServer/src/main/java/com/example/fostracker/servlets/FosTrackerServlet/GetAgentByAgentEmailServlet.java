/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.fostracker.servlets.FosTrackerServlet;

import com.example.fostracker.models.Coordinates;
import com.example.fostracker.models.Agent;
import com.example.fostracker.models.Name;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

import com.google.cloud.spanner.ResultSet;
import com.google.gson.JsonObject;

/**
 * Prints all the Agent details given Agent's email from Agents table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/agent/email").
 */

@WebServlet(value = "/agent/email")
public class GetAgentByAgentEmailServlet extends HttpServlet {

    //Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param agentDetailsRequest is GET request.
     * @param response            is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest agentDetailsRequest, HttpServletResponse response) throws ServletException, IOException {

        // Reads the json String using POST request.
        String json = agentDetailsRequest.getReader().readLine();

        // sets the response to json format.
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // output variable is used to write to response.
        PrintWriter output;
        output = response.getWriter();

        // If json is null ( No data was posted ) set the error to 403.
        if (json == null) {
            output.print("No data given");
            response.setStatus(403);
        } else {

            // Convert json string to json object to parse data.
            JsonObject jsonObj = new Gson().fromJson(json, JsonObject.class);

            // Get email from the JSON object.
            String agentEmail = jsonObj.get("agentEmail").getAsString();

            // Query the data with Agent's email.
            ResultSet agentData = AgentDatabaseHelper.queryByEmail(agentEmail);

            // agentDataIterator is a agent object that is used to store the row we are iterating.
            Agent agentDataIterator;
            // agentDataIteratorString stores the agentDataIterator object as json String.
            String agentDataIteratorString;

            // If agentData is not empty then prints all the rows else prints "No data exists".
            try {
                if (agentData == null) {
                    output.println("Data not found");
                } else if (agentData.next()) {
                    // stores the indexes of columns in verificationData ( ResultSet object ).
                    int columnAgentFirstNameIndex = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_FIRST_NAME);
                    int columnAgentMidNameIndex = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_MIDDLE_NAME);
                    int columnAgentLastNameIndex = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_LAST_NAME);
                    int columnAgentLatitudeIndex = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_LATITUDE);
                    int columnAgentLongitudeIndex = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_LONGITUDE);
                    int columnAgentPhoneIndex = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_PHONE);
                    int columnAgentCreationDataTime = agentData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_CREATION_DATE_TIME);

                    // define the json object and prints to the screen.
                    agentDataIterator = new Agent(
                            new Name(agentData.getString(columnAgentFirstNameIndex), agentData.getString(columnAgentMidNameIndex)
                                    , agentData.getString(columnAgentLastNameIndex)),
                            agentEmail,
                            agentData.getString(columnAgentPhoneIndex),
                            new Coordinates(agentData.getDouble(columnAgentLatitudeIndex),
                                    agentData.getDouble(columnAgentLongitudeIndex)),
                            agentData.getTimestamp(columnAgentCreationDataTime).toSqlTimestamp());

                    agentDataIteratorString = this.gson.toJson(agentDataIterator);

                    output.println(agentDataIteratorString);
                    agentData.close();
                } else {
                    response.setStatus(403);
                    output.print("No agent with given email id exists");
                    output.flush();
                }
            } catch (Exception e) {
                output.print(e);
            }

            // Prints success message.
            output.print("Successful");
            output.flush();
        }
    }
}

