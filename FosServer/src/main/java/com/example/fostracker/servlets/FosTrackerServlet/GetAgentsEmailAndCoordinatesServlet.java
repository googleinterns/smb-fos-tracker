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
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

import com.google.cloud.spanner.ResultSet;

/**
 * Prints the Agents email and coordinates from Agents table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/agents").
 */

@WebServlet(value = "/agents")
public class GetAgentsEmailAndCoordinatesServlet extends HttpServlet {

    // Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param agentEmailAndCoordinatesRequest is GET request.
     * @param response                        is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest agentEmailAndCoordinatesRequest, HttpServletResponse response) throws ServletException, IOException {

        // sets the response to json format.
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // output variable is used to write to response.
        PrintWriter output;
        output = response.getWriter();

        // agentDataIterator is a agent object that is used to store the row we are iterating.
        Agent agentDataIterator;
        // agentDataIteratorString stores the agentDataIterator object as json String.
        String agentDataIteratorString;

        // Querying the database table and storing in agentEmailAndCoordinateData.
        ResultSet agentsEmailAndCoordinatesData = AgentDatabaseHelper.queryAgentsEmailAndCoordinatesData();

        // If agentData is not empty then prints all the rows else prints "No data exists".
        if (agentsEmailAndCoordinatesData.next()) {
            // stores the indexes of columns in verificationData ( ResultSet object ).
            int columnAgentEmailIndex = agentsEmailAndCoordinatesData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_EMAIL);
            int columnAgentLatitudeIndex = agentsEmailAndCoordinatesData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_LATITUDE);
            int columnAgentLongitudeIndex = agentsEmailAndCoordinatesData.getColumnIndex(AgentDatabaseHelper.COLUMN_AGENT_LONGITUDE);

            // Loop through all rows and stores the row data in agentDataIterator. Converts agentDataIterator into
            // json object and prints to the screen.
            do {
                agentDataIterator = new Agent(agentsEmailAndCoordinatesData.getString(columnAgentEmailIndex),
                        new Coordinates(agentsEmailAndCoordinatesData.getDouble(columnAgentLatitudeIndex),
                                agentsEmailAndCoordinatesData.getDouble(columnAgentLongitudeIndex)));
                agentDataIteratorString = this.gson.toJson(agentDataIterator);
                output.println(agentDataIteratorString);
            } while (agentsEmailAndCoordinatesData.next());
            agentsEmailAndCoordinatesData.close();
        } else {
            response.setStatus(403);
            output.print("No data exists");
            output.flush();
        }

        // Prints success message.
        output.print("Successful");
        output.flush();
    }

}

