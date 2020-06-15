package com.example.fostracker.servlets;
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

import com.example.fostracker.models.Agent;
import com.example.fostracker.models.Coordinates;
import com.example.fostracker.models.Name;
import com.google.cloud.spanner.*;
import com.google.gson.Gson;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Contains the functions that make queries to the spanner database.
 */
public class SpannerTasks {

    private static DatabaseClient databaseClient = null;

    /**
     * Receives result of spanner sql query of fetching agent details from database whose
     * AgenetEmail is same as 'email'. It creates Agent object from ResultSet, converts Agent
     * object to json string and sends this string as response in resp.
     *
     * @param email email of agent whose details need to be fetched from spanner database.
     * @param resp  HttpServletResponse of GetAgentServlet where json string containing details
     *              of agent are written.
     */
    public static void getAgent(String email, HttpServletResponse resp) throws IOException {
        PrintWriter pw = resp.getWriter();
        ResultSet resultSet =
                SpannerClient.getDatabaseClient()
                        .singleUse()
                        .executeQuery(
                                Statement.of(
                                        "SELECT *\n"
                                                + "FROM Agents@{FORCE_INDEX=email}\n"
                                                + "WHERE AgentEmail = '" + email + "'"));

        Gson gson = new Gson();
        String firstName = "";
        String midName = "";
        String lastName = "";
        String agentEmail = "";
        String phone = "";
        Double latitude = 0.0;
        Double longitude = 0.0;
        while (resultSet.next()) {
            firstName = resultSet.getString("AgentFirstName");
            midName = resultSet.getString("AgentMidName");
            if (midName == null) {
                midName = "";
            }
            lastName = resultSet.getString("AgentLastName");
            agentEmail = resultSet.getString("AgentEmail");
            phone = resultSet.getString("AgentPhone");
            latitude = resultSet.getDouble("AgentLatitude");
            longitude = resultSet.getDouble("AgentLongitude");
        }

        Agent agent = new Agent(new Name(firstName, midName, lastName), agentEmail, phone, new Coordinates(latitude, longitude));

        String jsonResponse = gson.toJson(agent);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        pw.write(jsonResponse);
    }

    /**
     * Makes spanner query for counting the number of merchants verified by agent whose AgentEmail
     * is email. Writes the result as json string in response writer.
     *
     * @param email
     * @param resp
     * @throws IOException
     */
    public static void getNumberOfMerchantsVerified(String email, HttpServletResponse resp) throws IOException {
        PrintWriter pw = resp.getWriter();
        ResultSet resultSet =
                SpannerClient.getDatabaseClient()
                        .singleUse()
                        .executeQuery(
                                Statement.of(
                                        "SELECT COUNT(*) as MerchantsVerified\n"
                                                + "FROM VERIFICATIONS\n"
                                                + "WHERE AgentEmail = '" + email + "'"));
        long merchantVerified = 0;
        while (resultSet.next()) {
            merchantVerified = resultSet.getLong("MerchantsVerified");
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        pw.write("{ \"number_of_merchants\":" + Long.toString(merchantVerified) + "}");
    }

    /**
     * Makes spanner query for updating location of agent whose AgentEmail is email by setting
     * AgentLatitude to latitude and AgentLongitude to longitude. Writes the number or rows
     * affected in response writer.
     *
     * @param email
     * @param latitude
     * @param longitude
     * @param resp
     * @throws IOException
     */
    public static void updateAgentLocation(String email, double latitude, double longitude, HttpServletResponse resp) throws IOException {
        PrintWriter pw = resp.getWriter();
        resp.setContentType("text");
        resp.setCharacterEncoding("UTF-8");
        SpannerClient.getDatabaseClient()
                .readWriteTransaction()
                .run(
                        new TransactionRunner.TransactionCallable<Void>() {
                            @Override
                            public Void run(TransactionContext transaction) throws Exception {
                                String sql =
                                        "UPDATE Agents "
                                                + "SET AgentLatitude = " + Double.toString(latitude) + ", AgentLongitude = " + Double.toString(longitude)
                                                + " WHERE AgentEmail = '" + email + "'";
                                long rowCount = transaction.executeUpdate(Statement.of(sql));
                                pw.write(Long.toString(rowCount));
                                return null;
                            }
                        });
    }
}