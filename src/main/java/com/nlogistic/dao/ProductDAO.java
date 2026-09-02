package com.nlogistic.dao;

import com.nlogistic.model.Product;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {
    
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY product_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setCategory(rs.getString("category"));
                p.setHsnCode(rs.getString("hsn_code"));
                p.setUnitOfMeasure(rs.getString("unit_of_measure"));
                p.setUnitCost(rs.getDouble("unit_cost"));
                p.setUnitPrice(rs.getDouble("unit_price"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addProduct(Product p) {
        String sql = "{CALL add_product(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, p.getProductName());
            cs.setString(2, p.getCategory());
            cs.setString(3, p.getHsnCode());
            cs.setString(4, p.getUnitOfMeasure());
            cs.setDouble(5, p.getUnitCost());
            cs.setDouble(6, p.getUnitPrice());
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    public void deleteProduct(int productId, int requestingUserId) {
        String sql = "{CALL delete_products(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, productId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }
    
    public void updateProduct(int productId, int requestingUserId, String name, String category, String hsn, String uom, Double cost, Double price) {
        String sql = "{CALL update_products(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, productId);
            cs.setInt(2, requestingUserId);
            cs.setString(3, name);
            cs.setString(4, category);
            cs.setString(5, hsn);
            cs.setString(6, uom);
            if(cost != null) cs.setDouble(7, cost); else cs.setNull(7, java.sql.Types.DECIMAL);
            if(price != null) cs.setDouble(8, price); else cs.setNull(8, java.sql.Types.DECIMAL);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

}
