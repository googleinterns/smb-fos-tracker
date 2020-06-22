=======
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
import com.example.fostracker.models.Store;
import com.example.fostracker.models.Verification;
import com.example.fostracker.servlets.VerificationServlet.VerificationDatabaseHelper;
import com.google.cloud.spanner.ResultSet;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Prints the Store details with status verified by particular agent from Stores table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/agent/store/status").
 */

@WebServlet(value = "/agent/stores/status/")
public class GetStoresVerifiedByAgentServlet extends HttpServlet {

    // Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param agentVerifiedStoreDetailsRequest  GET request.
     * @param response                    HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest agentVerifiedStoreDetailsRequest, HttpServletResponse response)
            throws ServletException, IOException {

        // Reads the json String using POST request.
        String json = agentVerifiedStoreDetailsRequest.getReader().readLine();

        // sets the response to json format.
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // output variable is used to write to response.
        PrintWriter output;
        output = response.getWriter();

        if (json == null) {
            response.setStatus(403);
            output.println("No data given");
        } else {

            // Convert json string to json object to parse data.
            JsonObject jsonObj = new Gson().fromJson(json, JsonObject.class);

            // Get email from the JSON object.
            String agentEmail = jsonObj.get("agentEmail").getAsString();

            // storeAndStatusDataIterator is a Store object that is used to store the row we are iterating
            Store storeAndStatusDataIterator;
            // storeAndStatusDataIteratorString stores the storeAndCoordinateDataIterator object as json String.
            String storeAndStatusDataIteratorString;


            // Querying the database table for stores verified by the agent email and storing in the storeAndStatusData.
            ResultSet storeAndStatusData = VerificationDatabaseHelper.queryStoreAndStatusDataByEmail(agentEmail);

            // If storeAndStatusData is not empty then prints all the rows else prints "No data exists".
            if (storeAndStatusData.next()) {
                // stores the indexes of columns in storeAndStatusData ( ResultSet object ).
                int columnStorePhoneIndex =
                        storeAndStatusData.getColumnIndex(VerificationDatabaseHelper.COLUMN_STORE_PHONE);
                int columnStoreStatusIndex =
                        storeAndStatusData.getColumnIndex(VerificationDatabaseHelper.COLUMN_VERIFICATION_STATUS);
                // Loop through all rows and stores the row data in storeAndStatusDataIterator. Converts storeAndStatusDataIterator into
                // json object and prints to the screen.
                do {
                  
                    storeAndStatusDataIterator = new Store(storeAndStatusData.getString(columnStorePhoneIndex),
                            StoreDatabaseHelper.queryStoreCoordinatesUsingStorePhone(
                                    storeAndStatusData.getString(columnStorePhoneIndex)),
                            getStatusInt(storeAndStatusData.getString(columnStoreStatusIndex)
                    ));
                    storeAndStatusDataIteratorString = this.gson.toJson(storeAndStatusDataIterator);
                    output.println(storeAndStatusDataIteratorString);
                } while (storeAndStatusData.next());
                storeAndStatusData.close();
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

    /**
     * Converts the verification status into its corresponding integer.
     *
     * @param status  status of verification.
     * @return returns its corresponding integer.
     */
    private static int getStatusInt(String status) {
        switch (status) {
            case Verification.VERIFICATION_SUCCESSFUL:
                return Verification.VERIFICATION_SUCCESSFUL_INT;
            case Verification.VERIFICATION_UNSUCCESSFUL:
                return Verification.VERIFICATION_UNSUCCESSFUL_INT;
            case Verification.NOT_VERIFIED:
                return Verification.NOT_VERIFIED_INT;
            case Verification.NEEDS_REVISIT:
                return Verification.NEEDS_REVISIT_INT;
            default:
                return Verification.NOT_VERIFIED_INT;
        }
    }
}
