package com.example.fostracker.models;

import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

/**
 * Serves as a model for store objects that will be used in to communicate information about GPay Merchants' stores
 * and businesses
 */
public class Store {
    Name ownerName;
    String email;
    Address storeAddress;
    Coordinates coordinates;
    String phone;
    String storeName;
    Timestamp creationDateTime;
    String verificationStatus;

    /**
     * @param ownerName   - the name of the business owner
     * @param address     - the address of the store/business
     * @param email       - the gmail address associated with the account of the business owner
     * @param coordinates - the coordinates of the business taken when the owner confirms the business location
     * @param phone       - the phone number associated with the store. It is the primary identifier
     * @param storeName   - the name that is displayed on the store
     *                    creationDateTime is set by default to the current time of Asia/Kolkata and cannot be changed later
     */
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

    /**
     * @param ownerName        - the name of the business owner
     * @param address          - the address of the store/business
     * @param email            - the gmail address associated with the account of the business owner
     * @param coordinates      - the coordinates of the business taken when the owner confirms the business location
     * @param phone            - the phone number associated with the store. It is the primary identifier
     * @param storeName        - the name that is displayed on the store
     * @param creationDateTime is absolute time when merchant had been created.
     */
    public Store(Name ownerName,
                 Address address,
                 String email,
                 Coordinates coordinates,
                 String phone,
                 String storeName,
                 Timestamp creationDateTime
    ) {
        this.ownerName = ownerName;
        this.storeAddress = address;
        this.email = email;
        this.coordinates = coordinates;
        this.phone = phone;
        this.storeName = storeName;
        this.creationDateTime = creationDateTime;
    }

    /**
     * @param storePhone              - the store phone number that was verified
     * @param storeCoordinates        - the location the store
     * @param verificationStatus      - whether the verification was successful/unsuccessful/incomplete
     */
    public Store(String storePhone, Coordinates storeCoordinates, int verificationStatus, String storeName) {
        this.phone = storePhone;
        this.coordinates = storeCoordinates;
        this.verificationStatus = getStoreVerificationString(verificationStatus);
        this.storeName  = storeName;
    }

    /**
     * If store verification is successful then database table stores "green" String.
     * else if merchant is not registered then database table stores "grey" String
     * else if store verification is  unsuccessful then database table stores "red" String
     * else if merchant needs to be revisited then database table stores "grey" String
     */
    public static final String VERIFICATION_SUCCESSFUL = "green";
    public static final String NOT_VERIFIED = "grey";
    public static final String VERIFICATION_UNSUCCESSFUL = "red";
    public static final String NEEDS_REVISIT = "yellow";
    public static final int VERIFICATION_SUCCESSFUL_INT = 2;
    public static final int NOT_VERIFIED_INT = 0;
    public static final int VERIFICATION_UNSUCCESSFUL_INT = -1;
    public static final int NEEDS_REVISIT_INT = 1;

    /**
     * @param storePhone              - the store phone number that was verified
     * @param storeCoordinates        - the location the store
     * @param verificationStatus      - whether the verification was successful/unsuccessful/incomplete
     */
    public Store(String storePhone, Coordinates storeCoordinates, int verificationStatus) {
        this.phone = storePhone;
        this.coordinates = storeCoordinates;
        this.verificationStatus = getStoreVerificationString(verificationStatus);
    }

    //Based on the status integral value it sets to required status string
    private String getStoreVerificationString(int verificationStatus) {
        switch (verificationStatus) {
            case VERIFICATION_UNSUCCESSFUL_INT:
                return VERIFICATION_UNSUCCESSFUL;
            case VERIFICATION_SUCCESSFUL_INT:
                return VERIFICATION_SUCCESSFUL;
            case NOT_VERIFIED_INT:
                return NOT_VERIFIED;
            case NEEDS_REVISIT_INT:
                return NEEDS_REVISIT;
            default:
                return null;
        }
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

    public Name getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(Name ownerName) {
        this.ownerName = ownerName;
    }

    public String getStoreVerificationStatus() {
        return verificationStatus;
    }

    public void setStoreVerificationStatus(String status) {
        this.verificationStatus = status;
    }
}
