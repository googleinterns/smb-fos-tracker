/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.fostracker.servlets.AgentServlet;

import com.google.cloud.spanner.DatabaseClient;
import com.google.cloud.spanner.DatabaseId;
import com.google.cloud.spanner.Spanner;
import com.google.cloud.spanner.SpannerOptions;

import javax.servlet.annotation.WebListener;

/**
 * Creates databaseClient given Project ID, Instance ID and Database ID.
 */
@WebListener
public class SpannerClient {

    private static final String PROJECT_ID = "fos-tracker-278709";
    private static final String INSTANCE_ID = "fos-server-instance";
    private static final String DATABASE_ID = "fos-database";

    private static DatabaseClient databaseClient = null;
    private static Spanner spanner = null;

    public static DatabaseClient getDatabaseClient() {
        SpannerOptions options = SpannerOptions.newBuilder().build();
        spanner = options.getService();
        if (databaseClient == null) {
            databaseClient =
                    spanner.getDatabaseClient(DatabaseId.of(PROJECT_ID, INSTANCE_ID, DATABASE_ID));
        }
        return databaseClient;
    }

    static String getInstanceId() {
        return INSTANCE_ID;
    }

    static String getDatabaseId() {
        return DATABASE_ID;
    }

    static String getProjectId() {
        return PROJECT_ID;
    }

    static void closeSpanner() {
        if (spanner != null) {
            spanner.close();
        }
    }
}
