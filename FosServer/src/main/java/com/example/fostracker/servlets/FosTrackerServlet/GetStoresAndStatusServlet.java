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
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

import com.google.cloud.spanner.ResultSet;
import com.example.fostracker.servlets.VerificationServlet.VerificationDatabaseHelper;

/**
 * Prints the store phone, name, coordinates and status in verification table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/verification").
 */
@WebServlet(value = "/stores/status")
public class GetStoresAndStatusServlet extends HttpServlet {

    // Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param request  is GET request.
     * @param response is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // sets the response to json format.
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // output variable is used to write to response.
        PrintWriter output;
        output = response.getWriter();

        // storeAndCoordinateDataIterator is a Store object that is used to store the row we are iterating.
        Store storeAndCoordinateDataIterator;
        // storeAndCoordinateDataIteratorString stores the storeAndCoordinateDataIterator object as json String.
        String storeAndCoordinateDataIteratorString;

        // Querying the database table and storing in storeAndCoordinateData.
        ResultSet storeAndCoordinateData = StoreDatabaseHelper.queryStores();

        // If storeAndCoordinateData is not empty then prints all the rows else prints "No data exists".
        if (storeAndCoordinateData.next()) {
            // stores the indexes of columns in storeAndCoordinateData ( ResultSet object ).
            int columnStorePhoneIndex =
                    storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_PHONE);
            int columnStoreLatitudeIndex =
                    storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_LATITUDE);
            int columnStoreLongitudeIndex =
                    storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_LONGITUDE);
            int columnStoreNameIndex =
                    storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_NAME);

            // Loop through all rows and stores the row data in verificationDataIterator. Converts verificationDataIterator into
            // json object and prints to the screen.
            do {
                String status = VerificationDatabaseHelper
                        .queryStatusUsingStorePhone(storeAndCoordinateData.getString(columnStorePhoneIndex));
                int status_int = Verification.NOT_VERIFIED_INT;
                if (status != null) {
                    status_int = getStatusInt(status);
                }
                storeAndCoordinateDataIterator = new Store(storeAndCoordinateData.getString(columnStorePhoneIndex),
                        new Coordinates(storeAndCoordinateData.getDouble(columnStoreLatitudeIndex),
                                storeAndCoordinateData.getDouble(columnStoreLongitudeIndex)),
                        status_int,
                        storeAndCoordinateData.getString(columnStoreNameIndex)
                );
                storeAndCoordinateDataIteratorString = this.gson.toJson(storeAndCoordinateDataIterator);
                output.println(storeAndCoordinateDataIteratorString);
            } while (storeAndCoordinateData.next());
            storeAndCoordinateData.close();
        } else {
            output.print("No data exists");
            response.setStatus(403);
            output.flush();
        }

        // Prints success message.
        output.print("Successful");
        output.flush();
    }

    /**
     * Converts the verification status into its corresponding integer.
     *
     * @param status is status of verification.
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
                return 1;
        }
    }
}

