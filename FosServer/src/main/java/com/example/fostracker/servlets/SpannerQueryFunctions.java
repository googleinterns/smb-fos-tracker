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
     * Queries the database to get details of agent whose AgentEmail is same as 'email' passed as argument.
     * @param email email of agent whose details need to be fetched from spanner database.
     * @return resultSet containing agent details
     */
    public static ResultSet getAgent(String email) {
        ResultSet agentDetailsResultSet =
                SpannerClient.getDatabaseClient()
                        .singleUse()
                        .executeQuery(
                                Statement.of(
                                        "SELECT *\n"
                                                + "FROM Agents@{FORCE_INDEX=email}\n"
                                                + "WHERE AgentEmail = '" + email + "'"));

        return agentDetailsResultSet;
    }

    /**
     * Makes spanner query for counting the number of merchants verified by agent whose AgentEmail
     * is email.
     *
     * @param email
     * @return countOfMerchantVerifiedResultSet - Result set containing the numbe of merchants verified
     *          by agent
     */
    public static ResultSet getNumberOfMerchantsVerified(String email) {
        ResultSet countOfMerchantVerifiedResultSet =
                SpannerClient.getDatabaseClient()
                        .singleUse()
                        .executeQuery(
                                Statement.of(
                                        "SELECT COUNT(*) as MerchantsVerified\n"
                                                + "FROM VERIFICATIONS\n"
                                                + "WHERE AgentEmail = '" + email + "'"));
        return countOfMerchantVerifiedResultSet;
    }

    /**
     * Makes spanner query for updating location of agent whose AgentEmail is email by setting
     * AgentLatitude to latitude and AgentLongitude to longitude. Returns the number or rows
     * affected in response writer.
     *
     * @param email
     * @param latitude
     * @param longitude
     * @return number of rows affected by update operation
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