package com.example.fostracker.models;

import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

public class Store {
    Name ownerName;
    String email;
    Address storeAddress;
    Coordinates coordinates;
    String phone;
    String storeName;
    Timestamp creationDateTime;


    public Store(Name ownerName,
                 Address address,
                 String email,
                 Coordinates coordinates,
                 String phone,
                 String storeName
    ) {
        this.ownerName = ownerName;
        this.storeAddress = address;
        this.email = email;
        this.coordinates = coordinates;
        this.phone = phone;
        this.storeName = storeName;
        this.creationDateTime = Timestamp.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Kolkata")).toLocalDateTime());
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public String getMerchantEmail() {
        return email;
    }

    public void setMerchantEmail(String email) {
        this.email = email;
    }


    public Coordinates getStoreCoordinates() {
        return coordinates;
    }

    public void setStoreCoordinates(Coordinates coordinates) {
        this.coordinates = coordinates;
    }

    public String getStorePhone() {
        return phone;
    }

    public void setStorePhone(String phone) {
        this.phone = phone;
    }

    public Address getStoreAddress() {
        return storeAddress;
    }

    public void setStoreAddress(Address storeAddress) {
        this.storeAddress = storeAddress;
    }

    public Timestamp getStoreCreationDateTime() {
        return creationDateTime;
    }


}
