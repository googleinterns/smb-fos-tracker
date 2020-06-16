package com.example.fostracker.servlets;

import com.google.cloud.spanner.ResultSet;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Receives email of agent as post request. Passes email to the spanner query function
 * [getNumberofMerchantsVerified] that fetches the number of merchants this agent
 * has verified by counting in database.
 */
@WebServlet(name = "Number of merchants verified by an agent", value = "/number_of_merchants_verified")
public class NumberOfMerchantsVerified extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String jsonString = request.getReader().readLine();
        Gson gson = new Gson();
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        String agentEmail = jsonObject.get("email").getAsString();

        try {
            ResultSet resultSet = SpannerQueryFunctions.getNumberOfMerchantsVerified(agentEmail);
            long merchantVerified = 0;
            while (resultSet.next()) {
                merchantVerified = resultSet.getLong("MerchantsVerified");
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{ \"number_of_merchants\":" + merchantVerified + "}");

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}