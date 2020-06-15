package com.example.fostracker.servlets;

import com.example.fostracker.models.Email;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Receives email of agent as json string request and passes email and
 * HttpServletResponse resp to spanner task [task.agentAgent()] to get
 * data of agent corresponding to requested email from spanner database.
 */
@WebServlet(name = "get_agent", value = "/get_agent")
public class GetAgentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String jsonString = req.getReader().readLine();
        Gson gson = new Gson();
        Email email = gson.fromJson(jsonString, Email.class);
        try {
            SpannerTasks task = new SpannerTasks();
            task.getAgent(email.email, resp);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

    }
}
