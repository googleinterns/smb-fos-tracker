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

import com.example.fostracker.models.*;
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
 * Prints the Store details given Store phone from Stores table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/store/phone").
 */
@WebServlet(value = "/store/phone")
public class GetStoreByStorePhoneServlet extends HttpServlet {

    //Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param storeDetailsRequest is GET request.
     * @param response            is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest storeDetailsRequest, HttpServletResponse response) throws ServletException, IOException {

        // Reads the json String using POST request.
        String json = storeDetailsRequest.getReader().readLine();

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

            // Get phone from the JSON object.
            String storePhone = jsonObj.get("storePhone").getAsString();

            // Query the data with Store's phone number.
            ResultSet storeData = StoreDatabaseHelper.queryStoreUsingStorePhone(storePhone);

            // storeDataIterator is a agent object that is used to store the row we are iterating.
            Store storeDataIterator;
            // storeDataIteratorString stores the agentDataIterator object as json String.
            String storeDataIteratorString;


            // If storeData is not empty then prints all the rows else prints "No data exists".
            assert storeData != null;
            if (storeData.next()) {
                // stores the indexes of columns in verificationData ( ResultSet object ).
                int columnMerchantFirstNameIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_MERCHANT_FIRST_NAME);
                int columnMerchantMidNameIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_MERCHANT_MID_NAME);
                int columnMerchantLastNameIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_MERCHANT_LAST_NAME);
                int columnMerchantEmailIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_MERCHANT_EMAIL);
                int columnStoreNameIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_NAME);
                int columnStoreStreetIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_STREET);
                int columnStoreAreaIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_AREA);
                int columnStoreCityIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_CITY);
                int columnStoreStateIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_STATE);
                int columnStoreCountryIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_COUNTRY);
                int columnStorePincodeIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_PINCODE);
                int columnStoreLatitudeIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_LATITUDE);
                int columnStoreLongitudeIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_LONGITUDE);
                int columnStoreCreationDateTimeIndex = storeData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_CREATION_DATE_TIME);


                // define the json object and prints to the screen.
                storeDataIterator = new Store(
                        new Name(storeData.getString(columnMerchantFirstNameIndex), storeData.getString(columnMerchantMidNameIndex)
                                , storeData.getString(columnMerchantLastNameIndex)),
                        new Address(storeData.getString(columnStoreStreetIndex), storeData.getString(columnStoreAreaIndex)
                                , storeData.getString(columnStoreCityIndex), storeData.getString(columnStoreStateIndex)
                                , storeData.getString(columnStorePincodeIndex), storeData.getString(columnStoreCountryIndex)),
                        storeData.getString(columnMerchantEmailIndex),
                        new Coordinates(storeData.getDouble(columnStoreLatitudeIndex),
                                storeData.getDouble(columnStoreLongitudeIndex)),
                        storePhone,
                        storeData.getString(columnStoreNameIndex),
                        storeData.getTimestamp(columnStoreCreationDateTimeIndex).toSqlTimestamp());
                storeDataIteratorString = this.gson.toJson(storeDataIterator);
                output.println(storeDataIteratorString);
                storeData.close();
            } else {
                response.setStatus(403);
                output.print("No store with given phone number exists");
                output.flush();
            }

            // Prints success message.
            output.print("Successful");
            output.flush();
        }
    }
}

