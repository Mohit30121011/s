package com.nlogistic.dao;

import com.nlogistic.model.Customer;
import com.nlogistic.util.DBConnectionManager;
import java.sql.CallableStatement;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {
    
    public boolean registerCustomer(Customer c) {
        String sql = "INSERT INTO customers (user_id, customer_name, address, kyc_doc_path, credit_limit) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, c.getUserId());
            ps.setString(2, c.getCustomerName());
            ps.setString(3, c.getAddress());
            ps.setString(4, c.getKycDocPath());
            ps.setDouble(5, c.getCreditLimit());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
            return false; 
        }
    }
    
    public List<Customer> getAllCustomers() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM customers";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setCustomerName(rs.getString("customer_name"));
                c.setAddress(rs.getString("address"));
                c.setKycDocPath(rs.getString("kyc_doc_path"));
                c.setCreditLimit(rs.getDouble("credit_limit"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(c);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    /**
     * DB: delete_customers(p_customer_id, p_requesting_user_id) - Super Admin only
     */
    public void deleteCustomer(int customerId, int requestingUserId) {
        String sql = "{CALL delete_customers(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, customerId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: update_customers(p_customer_id, p_requesting_user_id, p_user_id, p_customer_name, p_address, p_credit_limit)
     */
    public void updateCustomer(int customerId, int requestingUserId, Integer userId, String customerName, String address, Double creditLimit) {
        String sql = "{CALL update_customers(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, customerId);
            cs.setInt(2, requestingUserId);
            if (userId != null) cs.setInt(3, userId); else cs.setNull(3, Types.INTEGER);
            if (customerName != null) cs.setString(4, customerName); else cs.setNull(4, Types.VARCHAR);
            if (address != null) cs.setString(5, address); else cs.setNull(5, Types.VARCHAR);
            if (creditLimit != null) cs.setDouble(6, creditLimit); else cs.setNull(6, Types.DECIMAL);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }


    private Customer mapCustomer(ResultSet rs) throws java.sql.SQLException {
        Customer c = new Customer();
        c.setCustomerId(rs.getInt("customer_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setCustomerName(rs.getString("customer_name"));
        c.setAddress(rs.getString("address"));
        c.setKycDocPath(rs.getString("kyc_doc_path"));
        c.setCreditLimit(rs.getDouble("credit_limit"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }

    /**
     * RBAC identity resolution (MEGA_PROMPT Step 1). Maps a logged-in Role 5 user
     * to their customers row so every downstream query can be scoped by customer_id.
     */
    public Customer getCustomerByUserId(int userId) {
        String sql = "SELECT * FROM customers WHERE user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapCustomer(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public Customer getCustomerById(int customerId) {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapCustomer(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
}
