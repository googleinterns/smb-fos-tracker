package com.example.fostracker.servlets;

import com.example.fostracker.models.Email;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Receives email of agent as post request. Passes email to the spanner task of
 * [getNumberofMerchantsVerified] that fetches the number of merchants this agent
 * has verified by counting in database.
 */
@WebServlet(name = "Number of merchants verified by an agent", value = "/number_of_merchants_verified")
public class NumberofMerchantsVerified extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String jsonString = req.getReader().readLine();
        Gson gson = new Gson();
        Email email = gson.fromJson(jsonString, Email.class);

        try {
            SpannerTasks task = new SpannerTasks();
            task.getNumberOfMerchantsVerified(email.email, resp);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}