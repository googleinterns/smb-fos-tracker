package com.example.fostracker.servlets.AgentServlet;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Receives email and current latitude and longitude of agent as post request. It passes these values
 * to the spanner task of [updateAgentLocation] that makes spanner sql query for updating.
 */
@WebServlet(name = "Update agent location", value = "/update_agent_location")
public class UpdateAgentLocation extends HttpServlet {

    class EmailCoordinates {
        String email;
        double latitude;
        double longitude;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String jsonString = request.getReader().readLine();
        Gson gson = new Gson();
        EmailCoordinates emailCoordinates = gson.fromJson(jsonString, EmailCoordinates.class);

        try {
            long numberOfRowsChanged = SpannerQueryFunctions.updateAgentLocation(emailCoordinates.email, emailCoordinates.latitude, emailCoordinates.longitude);
            response.setContentType("text");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(Long.toString(numberOfRowsChanged));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}