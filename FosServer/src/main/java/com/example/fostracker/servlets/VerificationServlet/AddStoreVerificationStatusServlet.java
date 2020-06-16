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

import com.google.gson.Gson;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.example.fostracker.models.Verification;

/**
 * Takes the new verification data from POST request and inserts into the verifications table.
 * <p>
 * If the data posted is null or insert is unsuccessful returns 403 error.
 * else keeps the status to 200.
 */
@WebServlet(value = "/verifications/new")
public class AddStoreVerificationStatusServlet extends HttpServlet {

    // gson is Gson object used to convert json file into Verification object
    private Gson gson = new Gson();

    /**
     * HTTP Post method prints that adds new Verfication data into table
     *
     * @param request is POST request.
     * @param response is HttpServletResponse object that is used to write the response.
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest verificationRequest, HttpServletResponse response) throws ServletException, IOException {

        // Reads the json String using POST request.
        String json = verificationRequest.getReader().readLine();

        // output is a PrintWriter object that prints response.
        PrintWriter output = response.getWriter();

        // If json is null ( No data was posted ) set the error to 403.
        if (json == null) {
            output.print("No data given");
            response.setStatus(403);
        } else {

            // Convert the json string into object.
            Verification newVerification = gson.fromJson(json, Verification.class);

            // Inserts the newVerification object to verifications table.
            boolean insertSuccessful = VerificationDatabaseHelper.writeData(newVerification);

            // If insert is successful sets status to 200 else sets to 403.
            if (insertSuccessful) {
                response.setStatus(200);
                response.getWriter().println("Successfully inserted");
            } else {
                response.setStatus(403);
                response.getWriter().println("Unsuccessful and cannot insert");
            }
        }
    }
}
