package com.nlogistic.test;

import com.nlogistic.dao.CompanyDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.Company;
import com.nlogistic.model.Customer;
import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

import java.sql.Connection;

public class Module1TestRunner {

    public static void main(String[] args) {
        System.out.println("=========================================");
        System.out.println("  STARTING MODULE 1 AUTOMATED TESTS      ");
        System.out.println("========================================="); System.out.println();

        int testsPassed = 0;
        int totalTests = 0;

        // Test 1: Database Connection
        totalTests++;
        System.out.print("Test 1: Testing DBConnectionManager... ");
        try (Connection conn = DBConnectionManager.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("[PASS]");
                testsPassed++;
            } else {
                System.out.println("[FAIL] - Connection is null or closed.");
            }
        } catch (Exception e) {
            System.out.println("[FAIL] - Exception: " + e.getMessage());
        }

        // Test 2: User Authentication (Invalid Credentials)
        totalTests++;
        System.out.print("Test 2: UserDAO Authentication (Invalid)... ");
        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.authenticate("wrong@email.com", "wrongpass");
            if (user == null) {
                System.out.println("[PASS]");
                testsPassed++;
            } else {
                System.out.println("[FAIL] - Should return null for invalid credentials.");
            }
        } catch (Exception e) {
            System.out.println("[FAIL] - Exception: " + e.getMessage());
        }

        // Test 3: Company Registration
//        totalTests++;
//        System.out.print("Test 3: CompanyDAO Registration... ");
//        try {
//            CompanyDAO companyDAO = new CompanyDAO();
//            Company c = new Company();
//            // Generate unique email to avoid unique constraint failure
//            String uniqueEmail = "test_comp_" + System.currentTimeMillis() + "@test.com";
//            c.setCompanyName("Test Automation Logistics");
//            c.setLicenseNo("LIC-" + System.currentTimeMillis());
//            c.setGstNo("GST-" + System.currentTimeMillis());
//            c.setAddress("123 Test Street");
//            c.setContactEmail(uniqueEmail);
//            c.setContactPhone("9998887776");
//
//            boolean success = companyDAO.registerCompany(c);
//            if (success) {
//                System.out.println("[PASS] - Company registered successfully.");
//                testsPassed++;
//            } else {
//                System.out.println("[FAIL] - Registration returned false.");
//            }
//        } catch (Exception e) {
//            System.out.println("[FAIL] - Exception: " + e.getMessage());
//        }
        
        

        // Test 4: Customer Registration
        totalTests++;
        System.out.print("Test 4: CustomerDAO Registration... ");
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            Customer c = new Customer();
            c.setUserId(2); // Assuming a valid user ID exists, but might fail due to FK if not handled. Let's use 1 which is admin.
            c.setUserId(1); 
            c.setCustomerName("Auto Test Customer");
            c.setAddress("456 Auto Road");
            c.setKycDocPath("/docs/dummy.pdf");
            c.setCreditLimit(50000.00);

            boolean success = customerDAO.registerCustomer(c);
            if (success) {
                System.out.println("[PASS] - Customer registered successfully.");
                testsPassed++;
            } else {
                System.out.println("[FAIL] - Customer registration failed (Possible unique constraint or FK issue).");
            }
        } catch (Exception e) {
            System.out.println("[FAIL] - Exception: " + e.getMessage());
        }

        System.out.println(); System.out.println("=========================================");
        System.out.println("  TEST SUMMARY: " + testsPassed + " / " + totalTests + " PASSED");
        System.out.println("=========================================");
    }
}

