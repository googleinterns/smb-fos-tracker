package com.example.fostracker.servlets;

import com.example.fostracker.models.Agent;
import com.example.fostracker.models.Coordinates;
import com.example.fostracker.models.Name;
import com.google.cloud.spanner.ResultSet;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Gson gson = new Gson();
        String jsonString = request.getReader().readLine();
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        String agentEmail = jsonObject.get("email").getAsString();

        Agent agent = null;
        try {
            ResultSet resultSet = SpannerQueryFunctions.getAgent(agentEmail);

            while (resultSet.next()) {
                String firstName = resultSet.getString("AgentFirstName");
                String midName = resultSet.getString("AgentMidName");
                if (midName.isEmpty()) {
                    midName = "";
                }
                String lastName = resultSet.getString("AgentLastName");
                agentEmail = resultSet.getString("AgentEmail");
                String phone = resultSet.getString("AgentPhone");
                Double latitude = resultSet.getDouble("AgentLatitude");
                Double longitude = resultSet.getDouble("AgentLongitude");
                agent = new Agent(new Name(firstName, midName, lastName), agentEmail, phone, new Coordinates(latitude, longitude));
            }


            String jsonResponse = gson.toJson(agent);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonResponse);

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

    }
}
