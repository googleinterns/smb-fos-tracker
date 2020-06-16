package com.example.fostracker.servlets;

import com.example.fostracker.models.Store;
import com.google.cloud.Timestamp;
import com.google.cloud.spanner.*;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet(value = "/stores/add")
public class AddStoreServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String json = req.getReader().readLine();
        if (json == null) {
            resp.setStatus(403);
            resp.getWriter().println("No body was given");
            return;
        }
        Gson gson = new Gson();
        Store store = gson.fromJson(json, Store.class);
        SpannerOptions spannerOptions = SpannerOptions.newBuilder().build();
        Spanner spanner = spannerOptions.getService();
        DatabaseClient databaseClient = spanner.getDatabaseClient(DatabaseId.of("fos-tracker-278709", "fos-server-instance", "fos-database"));
        List<Mutation> mutations = new ArrayList<>();
        mutations.add(
                Mutation.newInsertBuilder("Stores")
                        .set("StorePhone")
                        .to(store.getStorePhone())
                        .set("MerchantEmail")
                        .to(store.getMerchantEmail())
                        .set("MerchantFirstName")
                        .to(store.getOwnerName().getFirstName())
                        .set("MerchantMiddleName")
                        .to(store.getOwnerName().getMiddleName())
                        .set("MerchantLastName")
                        .to(store.getOwnerName().getLastName())
                        .set("StoreArea")
                        .to(store.getStoreAddress().getArea())
                        .set("StoreCity")
                        .to(store.getStoreAddress().getCity())
                        .set("StoreCountry")
                        .to(store.getStoreAddress().getCountry())
                        .set("StoreStreet")
                        .to(store.getStoreAddress().getStreet())
                        .set("StorePincode")
                        .to(store.getStoreAddress().getPincode())
                        .set("StoreState")
                        .to(store.getStoreAddress().getState())
                        .set("StoreName")
                        .to(store.getStoreName())
                        .set("StoreLatitude")
                        .to(store.getStoreCoordinates().getLatitude())
                        .set("StoreLongitude")
                        .to(store.getStoreCoordinates().getLongitude())
                        .set("StoreCreationDateTime")
                        .to(Timestamp.of(java.sql.Timestamp.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Kolkata")).toLocalDateTime())))
                        .build());
        try {
            databaseClient.write(mutations);
            resp.setStatus(200);
            resp.getWriter().println("Successful");
        } catch (SpannerException e) {
            e.printStackTrace();
            resp.setStatus(403);
            resp.getWriter().println("Unsuccessful");
        }


    }
}
