package com.nlogistic.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DataSeeder {
    public static void main(String[] args) {
        String sqlFilePath = "c:\\Users\\mohit\\Downloads\\NLogisitc_Backend\\massive_dummy_data.sql";
        String URL = "jdbc:mysql://localhost:3306/nlogistic_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String content = new String(Files.readAllBytes(Paths.get(sqlFilePath)), "UTF-8");
            String[] statements = content.split(";");
            
            try (Connection conn = DriverManager.getConnection(URL, "root", "");
                 Statement stmt = conn.createStatement()) {
                 
                for (String s : statements) {
                    if (s.trim().length() > 0) {
                        System.out.println("Executing: " + s.substring(0, Math.min(s.length(), 40)).replace("\n", " ") + "...");
                        try {
                            stmt.execute(s.trim());
                        } catch (Exception ex) {
                            System.out.println("  -> Skipped/Error: " + ex.getMessage());
                        }
                    }
                }
                System.out.println("MASSIVE DUMMY DATA SEEDING COMPLETE!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
