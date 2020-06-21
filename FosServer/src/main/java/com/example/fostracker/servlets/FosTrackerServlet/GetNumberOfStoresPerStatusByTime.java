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

import com.google.cloud.Date;
import com.google.gson.Gson;
import com.google.cloud.spanner.*;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;

import com.google.cloud.spanner.ResultSet;

/**
 * Prints the total number of stores registered and verified categorized by verification status in JSON format based on a given starting and ending date.
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/number_of_stores_per_status_by_time").
 */

@WebServlet(value = "/number_of_stores_per_status_by_time")
public class GetNumberOfStoresPerStatusByTime extends HttpServlet {

    class StartEndTime {
        String startTime;
        String endTime;

        StartEndTime(String startTime, String endTime) {
            this.startTime = startTime;
            this.endTime = endTime;
        }
    }

    // Gson object that is used to convert Strings into JSON objects
    private final Gson gson = new Gson();

    /**
     * HTTP Post method prints the query as response.
     *
     * @param request  is Post request.
     * @param response is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String json = request.getReader().readLine();
        if (json == null) {
            response.setStatus(403);
            response.getWriter().println("No body was given");
            return;
        }
        StartEndTime startEndTime = gson.fromJson(json, StartEndTime.class);
        DatabaseClient databaseClient = null;
        try {
            SpannerOptions spannerOptions = SpannerOptions.newBuilder().build();
            Spanner spanner = spannerOptions.getService();
            databaseClient = spanner.getDatabaseClient(DatabaseId.of("fos-tracker-278709", "fos-server-instance", "fos-database"));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(405);
            response.getWriter().println("Spanner connection error");
        }
        ResultSet registered = null;
        ResultSet successful = null;
        ResultSet failed = null;
        ResultSet revisit = null;

        try {
            assert databaseClient != null;
            String query = "SELECT EXTRACT(DATE FROM STORECREATIONDATETIME) AS Date, COUNT(*) AS NumberOfStores FROM STORES WHERE STORECREATIONDATETIME BETWEEN TIMESTAMP(\"" + startEndTime.startTime + "\") AND TIMESTAMP_ADD(TIMESTAMP(\"" + startEndTime.endTime + "\"), INTERVAL 1 DAY) GROUP BY EXTRACT(DATE FROM STORECREATIONDATETIME);";
            registered = databaseClient.singleUse().executeQuery(Statement.of(query));
            query = "SELECT EXTRACT(DATE FROM VERIFICATIONTIME) AS Date, COUNT(*) AS NumberOfStores FROM VERIFICATIONS WHERE VERIFICATIONSTATUS = \"red\" AND VERIFICATIONTIME BETWEEN TIMESTAMP(\"" + startEndTime.startTime + "\") AND TIMESTAMP_ADD(TIMESTAMP(\"" + startEndTime.endTime + "\"), INTERVAL 1 DAY) GROUP BY EXTRACT(DATE FROM VERIFICATIONTIME);";
            failed = databaseClient.singleUse().executeQuery(Statement.of(query));
            query = "SELECT EXTRACT(DATE FROM VERIFICATIONTIME) AS Date, COUNT(*) AS NumberOfStores FROM VERIFICATIONS WHERE VERIFICATIONSTATUS = \"green\" AND VERIFICATIONTIME BETWEEN TIMESTAMP(\"" + startEndTime.startTime + "\") AND TIMESTAMP_ADD(TIMESTAMP(\"" + startEndTime.endTime + "\"), INTERVAL 1 DAY) GROUP BY EXTRACT(DATE FROM VERIFICATIONTIME);";
            successful = databaseClient.singleUse().executeQuery(Statement.of(query));
            query = "SELECT EXTRACT(DATE FROM VERIFICATIONTIME) AS Date, COUNT(*) AS NumberOfStores FROM VERIFICATIONS WHERE VERIFICATIONSTATUS = \"yellow\" AND VERIFICATIONTIME BETWEEN TIMESTAMP(\"" + startEndTime.startTime + "\") AND TIMESTAMP_ADD(TIMESTAMP(\"" + startEndTime.endTime + "\"), INTERVAL 1 DAY) GROUP BY EXTRACT(DATE FROM VERIFICATIONTIME);";
            revisit = databaseClient.singleUse().executeQuery(Statement.of(query));

            ResultSet[] keys = {registered, failed, successful, revisit};
            String[] keyStrings = {"registered", "failed", "successful", "revisit"};
            HashMap<String, HashMap<String, Long>> resultMap = new HashMap<>();

            for (int i = 0; i < 4; i++) {
                ResultSet category = keys[i];

                // HashMap for storing the number of merchants in each status category.
                HashMap<String, Long> statusToNumberOfStoresMap = new HashMap<>();

                // If data is not empty then prints all the rows else prints "No data exists".
                if (category.next()) {

                    // Loop through all rows and set key as verification status and value as number of stores in hashmap.
                    do {
                        Long value = category.getLong("NumberOfStores");
                        Date date = category.getDate("Date");
                        String dateString = date.toString();
                        statusToNumberOfStoresMap.put(dateString, value);

                    } while (category.next());

                    resultMap.put(keyStrings[i], statusToNumberOfStoresMap);
                    category.close();
                }
            }
            String responseJson = gson.toJson(resultMap);
            response.getWriter().write(responseJson);
            response.getWriter().flush();
        } catch (SpannerException e) {
            e.printStackTrace();
            response.setStatus(403);
            response.getWriter().println("Unsuccessful");
        }
    }
}

