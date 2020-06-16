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

package com.example.fostracker.servlets.VerificationServlet;

import com.example.fostracker.models.Coordinates;
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

/**
 * Prints the complete verification table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/verification").
 */
@WebServlet(value = "/verification")
public class GetStoreVerificationsServlet extends HttpServlet {

    //Gson object that is used to convert Strings into JSON objects
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

        // verificationDataIterator is a Verification object that is used to store the row we are iterating.
        Verification verificationDataIterator;
        // verificationDataIteratorString stores the VerificationDataIterator object as json String.
        String verificationDataIteratorString;

        // Querying the database table and storing in verificationData.
        ResultSet verificationData = VerificationDatabaseHelper.queryData();

        // If verificationData is not empty then prints all the rows else prints "No data exists".
        if (verificationData.next()) {
            // stores the indexes of columns in verificationData ( ResultSet object ).
            int columnAgentEmailIndex =
                    verificationData.getColumnIndex(VerificationDatabaseHelper.COLUMN_AGENT_EMAIL);
            int columnStorePhoneIndex =
                    verificationData.getColumnIndex(VerificationDatabaseHelper.COLUMN_STORE_PHONE);
            int columnVerificationLatitudeIndex =
                    verificationData.getColumnIndex(VerificationDatabaseHelper.COLUMN_VERIFICATION_LATITUDE);
            int columnVerificationLongitudeIndex =
                    verificationData.getColumnIndex(VerificationDatabaseHelper.COLUMN_VERIFICATION_LONGITUDE);
            int columnVerificationStatusIndex =
                    verificationData.getColumnIndex(VerificationDatabaseHelper.COLUMN_VERIFICATION_STATUS);
            int columnVerificationTimeIndex =
                    verificationData.getColumnIndex(VerificationDatabaseHelper.COLUMN_VERIFICATION_TIME);

            // Loop through all rows and stores the row data in verificationDataIterator. Converts verificationDataIterator into
            // json object and prints to the screen.
            do {
                verificationDataIterator = new Verification(verificationData.getString(columnAgentEmailIndex),
                        verificationData.getString(columnStorePhoneIndex),
                        new Coordinates(verificationData.getDouble(columnVerificationLatitudeIndex),
                                verificationData.getDouble(columnVerificationLongitudeIndex)),
                        getStatusInt(verificationData.getString(columnVerificationStatusIndex)),
                        verificationData.getTimestamp(columnVerificationTimeIndex).toSqlTimestamp());
                verificationDataIteratorString = this.gson.toJson(verificationDataIterator);
                output.printf(verificationDataIteratorString);
            } while (verificationData.next());
            verificationData.close();
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

