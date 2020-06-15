package com.example.fostracker.servlets;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String jsonString = req.getReader().readLine();
        Gson gson = new Gson();
        EmailCoordinates emailCoordinates = gson.fromJson(jsonString, EmailCoordinates.class);

        try {
            SpannerTasks task = new SpannerTasks();
            task.updateAgentLocation(emailCoordinates.email, emailCoordinates.latitude, emailCoordinates.longitude, resp);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}