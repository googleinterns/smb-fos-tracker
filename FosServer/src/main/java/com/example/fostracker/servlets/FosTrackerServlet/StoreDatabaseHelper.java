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

import com.google.cloud.spanner.ResultSet;
import com.google.cloud.spanner.SpannerException;
import com.google.cloud.spanner.Statement;

import com.example.fostracker.models.Coordinates;
import com.example.fostracker.servlets.VerificationServlet.SpannerClient;

/**
 * This class contains operations on Stores table.
 * <p>
 * Stores required column names in constant Strings and these constants are used whenever column name needs to be referred.
 * Query the store coordinates based on store phone number in stores table
 */
public class StoreDatabaseHelper {

    // Column names are stored in these constant Strings.
    public final static String TABLE_NAME = "Stores";
    public final static String COLUMN_STORE_PHONE = "StorePhone";
    public final static String COLUMN_STORE_LATITUDE = "StoreLatitude";
    public final static String COLUMN_STORE_LONGITUDE = "StoreLongitude";
    public final static String COLUMN_MERCHANT_EMAIL = "MerchantEmail";
    public final static String COLUMN_MERCHANT_FIRST_NAME = "MerchantFirstName";
    public final static String COLUMN_MERCHANT_MID_NAME = "MerchantMiddleName";
    public final static String COLUMN_MERCHANT_LAST_NAME = "MerchantLastName";
    public final static String COLUMN_STORE_AREA = "StoreArea";
    public final static String COLUMN_STORE_CITY = "StoreCity";
    public final static String COLUMN_STORE_COUNTRY = "StoreCountry";
    public final static String COLUMN_STORE_NAME = "StoreName";
    public final static String COLUMN_STORE_PINCODE = "StorePincode";
    public final static String COLUMN_STORE_STREET = "StoreStreet";
    public final static String COLUMN_STORE_STATE = "StoreState";
    public final static String COLUMN_STORE_CREATION_DATE_TIME = "StoreCreationDateTime";
    // This constant stores the query store phone name
    private final static String QUERY_STORE_PHONE = "storePhone";
    private final static String QUERY_STORE_PINCODE = "storePincode";


    /**
     * Queries the store table for store coordinates based on store phone number
     *
     * @return ResultSet object that refers to corresponding row
     */
    public static Coordinates queryStoreCoordinatesUsingStorePhone(String storePhone) {

        Coordinates storeCoordinates;

        // SQL statement to query store coordinates using store phone number.
        Statement statement =
                Statement.newBuilder(
                        "SELECT " + COLUMN_STORE_LATITUDE + ", "
                                + COLUMN_STORE_LONGITUDE
                                + " FROM " + TABLE_NAME
                                + " WHERE " + COLUMN_STORE_PHONE
                                + " = @" + QUERY_STORE_PHONE)
                        .bind(QUERY_STORE_PHONE)
                        .to(storePhone)
                        .build();
        // Tries to query if it fails returns null.
        try (ResultSet storeCoordinateData =
                     SpannerClient.getDatabaseClient().singleUse().executeQuery(statement)) {
            if (storeCoordinateData.next()) {
                int columnStoreLatitudeIndex =
                        storeCoordinateData.getColumnIndex(COLUMN_STORE_LATITUDE);
                int columnStoreLongitudeIndex =
                        storeCoordinateData.getColumnIndex(COLUMN_STORE_LONGITUDE);
                storeCoordinates = new Coordinates(storeCoordinateData.getDouble(columnStoreLatitudeIndex),
                        storeCoordinateData.getDouble(columnStoreLongitudeIndex));
                return storeCoordinates;
            } else {
                return null;
            }
        } catch (SpannerException e) {
            return null;
        }
    }

    /**
     * Queries the store table for store details based on store phone number
     *
     * @return ResultSet object that refers to corresponding row
     */
    public static ResultSet queryStoreUsingStorePhone(String storePhone) {

        // SQL statement to query store coordinates using store phone number.
        Statement statement =
                Statement.newBuilder(
                        "SELECT " + COLUMN_MERCHANT_FIRST_NAME + ", " + COLUMN_MERCHANT_MID_NAME
                                + ", " + COLUMN_MERCHANT_LAST_NAME + ", " + COLUMN_MERCHANT_EMAIL
                                + ", " + COLUMN_STORE_NAME + ", "
                                + COLUMN_STORE_LATITUDE + ", " + COLUMN_STORE_LONGITUDE
                                + ", " + COLUMN_STORE_STREET + ", " + COLUMN_STORE_AREA
                                + ", " + COLUMN_STORE_CITY + ", " + COLUMN_STORE_STATE
                                + ", " + COLUMN_STORE_COUNTRY + ", " + COLUMN_STORE_PINCODE
                                + ", " + COLUMN_STORE_CREATION_DATE_TIME
                                + " FROM " + TABLE_NAME
                                + " WHERE " + COLUMN_STORE_PHONE
                                + " = @" + QUERY_STORE_PHONE)
                        .bind(QUERY_STORE_PHONE)
                        .to(storePhone)
                        .build();
        // Tries to query if it fails returns null.
        try {
            ResultSet storeData =
                    SpannerClient.getDatabaseClient().singleUse().executeQuery(statement);
            return storeData;
        } catch (SpannerException e) {
            return null;
        }
    }

    /**
     * Queries the store table for store coordinates based on pincode.
     *
     * @return ResultSet object that refers to corresponding row
     */
    public static ResultSet queryStoresUsingPincode(String pincode) {

        // SQL statement to query store coordinates using pincode.
        Statement statement =
                Statement.newBuilder(
                        "SELECT "
                                + COLUMN_STORE_LATITUDE + ", " + COLUMN_STORE_LONGITUDE
                                + ", " + COLUMN_STORE_PHONE
                                + " FROM " + TABLE_NAME
                                + " WHERE " + COLUMN_STORE_PINCODE
                                + " = @" + QUERY_STORE_PINCODE)
                        .bind(QUERY_STORE_PINCODE)
                        .to(pincode)
                        .build();
        // Tries to query if it fails returns null.
        try {
            ResultSet storeData =
                    SpannerClient.getDatabaseClient().singleUse().executeQuery(statement);
            return storeData;
        } catch (SpannerException e) {
            return null;
        }
    }

    /**
     * Queries the store table for store coordinates, store name and store phone.
     *
     * @return ResultSet object that refers to corresponding row
     */
    public static ResultSet queryStores() {

        // SQL statement to query store coordinates using store phone number.
        Statement statement =
                Statement.newBuilder(
                        "SELECT "
                                + COLUMN_STORE_LATITUDE + ", " + COLUMN_STORE_LONGITUDE
                                + ", " + COLUMN_STORE_PHONE+ ", " + COLUMN_STORE_NAME
                                + " FROM " + TABLE_NAME).build();
        // Tries to query if it fails returns null.
        try {
            ResultSet storeData =
                    SpannerClient.getDatabaseClient().singleUse().executeQuery(statement);
            return storeData;
        } catch (SpannerException e) {
            return null;
        }
    }

}
