package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/ledger")
public class LedgerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        List<Map<String, Object>> ledgerList = new ArrayList<>();
        
        // Fetch ledger entries for the company's products
        String sql = "SELECT l.txn_date, p.product_name, p.hsn_code, l.transaction_type, l.quantity, l.unit_cost_at_txn, l.reference_type "
                   + "FROM inventory_ledger l "
                   + "JOIN products p ON l.product_id = p.product_id "
                   + "JOIN stock s ON p.product_id = s.product_id "
                   + "WHERE s.company_id = ? "
                   + "GROUP BY l.ledger_id " // Prevent duplicates if multiple stock locations exist for same product
                   + "ORDER BY l.txn_date DESC LIMIT 100";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, user.getCompanyId());
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getTimestamp("txn_date"));
                    row.put("productName", rs.getString("product_name"));
                    row.put("hsnCode", rs.getString("hsn_code"));
                    row.put("type", rs.getString("transaction_type")); // IN, OUT, ADJUSTMENT
                    row.put("quantity", rs.getDouble("quantity"));
                    row.put("unitCost", rs.getDouble("unit_cost_at_txn"));
                    row.put("reference", rs.getString("reference_type"));
                    ledgerList.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("ledgerList", ledgerList);
        request.getRequestDispatcher("/jsp/ledger.jsp").forward(request, response);
    }
}
