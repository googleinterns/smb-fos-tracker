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

import com.google.gson.Gson;
import com.google.cloud.spanner.*;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.*;

import com.google.cloud.spanner.ResultSet;

/**
 * Prints the total number of stores by verification status in JSON format based on region selected.
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/number_of_stores_by_status").
 */

@WebServlet(value = "/number_of_stores_per_status_by_region")
public class GetNumberOfStoresPerStatusByRegion extends HttpServlet {

    class RegionCategoryValue {
        String regionCategory;
        String regionValue;

        RegionCategoryValue(String regionCategory, String regionValue) {
            this.regionCategory = regionCategory;
            this.regionValue = regionValue;
        }
    }

    // Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param request  is POST request.
     * @param response is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String json = request.getReader().readLine();
        if (json == null) {
            response.setStatus(403);
            response.getWriter().println("No body was given");
            return;
        }
        RegionCategoryValue regionCategoryValue = gson.fromJson(json, RegionCategoryValue.class);
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
        ResultSet resultSet = null;
        HashSet<String> validCategories = new HashSet<String>();
        validCategories.add("STATE");
        validCategories.add("CITY");
        validCategories.add("PINCODE");

        try {
            if (validCategories.contains(regionCategoryValue.regionCategory)) {
                String query = "SELECT VerificationStatus, COUNT(*) AS NumberOfStores FROM Verifications FULL JOIN Stores ON Stores.StorePhone = Verifications.StorePhone" +
                        " WHERE UPPER(STORE" + regionCategoryValue.regionCategory + ") = \"" + regionCategoryValue.regionValue + "\" GROUP BY VerificationStatus";
                resultSet = databaseClient.singleUse().executeQuery(Statement.of(query));
            } else {
                resultSet = databaseClient.singleUse().executeQuery(Statement.of("SELECT VerificationStatus, COUNT(*) AS NumberOfStores FROM Verifications FULL JOIN Stores " +
                        "ON Stores.StorePhone = Verifications.StorePhone GROUP BY VerificationStatus"));
            }

            // HashMap for storing the number of merchants in each status category.
            HashMap<String, Long> statusToNumberOfStoresMap = new HashMap<>();

            // If data is not empty then prints all the rows else prints "No data exists".
            if (resultSet.next()) {

                // Loop through all rows and set key as verification status and value as number of stores in hashmap.
                do {
                    Long value = resultSet.getLong("NumberOfStores");
                    String key = "UNVISITED";
                    if (resultSet.isNull("VerificationStatus") == false) {
                        key = resultSet.getString("VerificationStatus");
                    }
                    statusToNumberOfStoresMap.put(key, value);

                } while (resultSet.next());

                String responseJson = gson.toJson(statusToNumberOfStoresMap);
                response.getWriter().write(responseJson);
                resultSet.close();
            }
            response.getWriter().flush();
        } catch (SpannerException e) {
            e.printStackTrace();
            response.setStatus(403);
            response.getWriter().println("Unsuccessful");
            return;
        }

    }
}

