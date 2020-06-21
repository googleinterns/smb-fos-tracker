package com.example.fostracker.servlets.AgentServlet;
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

import com.google.cloud.spanner.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Contains the functions that make queries to the spanner database.
 */
public class SpannerQueryFunctions {

    private static DatabaseClient databaseClient = null;

    /**
     * Receives result of spanner sql query of fetching agent details from database whose
     * AgentEmail is same as 'email'. It creates Agent object from ResultSet, converts Agent
     * object to json string and sends this string as response in resp.
     *
     * @param email email of agent whose details need to be fetched from spanner database.
     */
    public static ResultSet getAgent(String email) {
        ResultSet resultSet =
                SpannerClient.getDatabaseClient()
                        .singleUse()
                        .executeQuery(
                                Statement.of(
                                        "SELECT *\n"
                                                + "FROM Agents@{FORCE_INDEX=email}\n"
                                                + "WHERE AgentEmail = '" + email + "'"));

        return resultSet;
    }

    /**
     * Makes spanner query for counting the number of merchants verified by agent whose AgentEmail
     * is email. Writes the result as json string in response writer.
     *
     * @param email
     */
    public static ResultSet getNumberOfMerchantsVerified(String email) {
        ResultSet resultSet =
                SpannerClient.getDatabaseClient()
                        .singleUse()
                        .executeQuery(
                                Statement.of(
                                        "SELECT COUNT(*) as MerchantsVerified\n"
                                                + "FROM VERIFICATIONS\n"
                                                + "WHERE AgentEmail = '" + email + "'"));
        return resultSet;
    }

    /**
     * Makes spanner query for updating location of agent whose AgentEmail is email by setting
     * AgentLatitude to latitude and AgentLongitude to longitude. Writes the number or rows
     * affected in response writer.
     *
     * @param email
     * @param latitude
     * @param longitude
     * @return the number of rows changed when agent latitude and longitude were changed.
     *          Return value can either be 0 in case of no agent of given email or 1 since there
     *          AgentEmail is unique per agent entry.
     */
    public static long updateAgentLocation(String email, double latitude, double longitude) {
        final long[] numberOfRowsAffected = new long[1];
        SpannerClient.getDatabaseClient()
                .readWriteTransaction()
                .run(
                        new TransactionRunner.TransactionCallable<Void>() {
                            @Override
                            public Void run(TransactionContext transaction) throws Exception {
                                String sql =
                                        "UPDATE Agents "
                                                + "SET AgentLatitude = " + latitude + ", AgentLongitude = " + longitude
                                                + " WHERE AgentEmail = '" + email + "'";
                                long rowCount = transaction.executeUpdate(Statement.of(sql));
                                numberOfRowsAffected[0] = rowCount;
                                return null;
                            }
                        });
        return numberOfRowsAffected[0];
    }
}