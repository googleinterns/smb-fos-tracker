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
 * Prints the Store details with status based on given pincode from Stores table in JSON format.
 * <p>
 * This Servlet converts the ResultSet into JSON object and prints to the response on @WebServlet(value = "/stores/status/pincode").
 */

@WebServlet(value = "/stores/status/pincode")
public class GetStoresAndStatusByPincodeServlet extends HttpServlet {

    // Gson object that is used to convert Strings into JSON objects
    private Gson gson = new Gson();

    /**
     * HTTP Get method prints the query as response.
     *
     * @param verificationDetailsRequest is GET request.
     * @param response                   is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest verificationDetailsRequest, HttpServletResponse response) throws ServletException, IOException {

        // Reads the json String using POST request.
        String json = verificationDetailsRequest.getReader().readLine();

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

            // Get pincode from the JSON object.
            String storePincode = jsonObj.get("storePincode").getAsString();

            // storeAndCoordinateDataIterator is a Store object that is used to store the row we are iterating.
            Store storeAndCoordinateDataIterator;
            // storeAndCoordinateDataIteratorString stores the storeAndCoordinateDataIterator object as json String.
            String storeAndCoordinateDataIteratorString;


            // Querying the database table and storing in storeAndCoordinateData.
            ResultSet storeAndCoordinateData = StoreDatabaseHelper.queryStoresUsingPincode(storePincode);

            // If storeAndStatusData is not empty then prints all the rows else prints "No data exists".
            if (storeAndCoordinateData.next()) {
                // stores the indexes of columns in storeAndCoordinateData ( ResultSet object ).
                int columnStorePhoneIndex =
                        storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_PHONE);
                int columnStoreLatitudeIndex =
                        storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_LONGITUDE);
                int columnStoreLongitudeIndex =
                        storeAndCoordinateData.getColumnIndex(StoreDatabaseHelper.COLUMN_STORE_LATITUDE);

                // Loop through all rows and stores the row data in storeAndCoordinateDataIterator. Converts storeAndCoordinateDataIterator into
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
                            status_int
                    );
                    storeAndCoordinateDataIteratorString = this.gson.toJson(storeAndCoordinateDataIterator);
                    output.println(storeAndCoordinateDataIteratorString);
                } while (storeAndCoordinateData.next());
                storeAndCoordinateData.close();
//                response.setStatus(200);
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
                return Verification.NOT_VERIFIED_INT;
        }
    }


}
