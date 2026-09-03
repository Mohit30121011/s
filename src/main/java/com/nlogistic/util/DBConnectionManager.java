package com.nlogistic.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnectionManager {
	private static final String URL = "jdbc:mysql://localhost:3306/nlogistic_db?useSSL=false&serverTimezone=Asia/Kolkata&allowPublicKeyRetrieval=true";
	private static final String USER = "root";
	private static final String PASSWORD = "NewPassword123!";                

	static {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");            
		} catch (ClassNotFoundException e) {          			 
			e.printStackTrace();
			throw new RuntimeException("MySQL JDBC Driver not found.");
		}     
	}              

	public static Connection getConnection() throws SQLException {   
		try {
			return DriverManager.getConnection(URL, USER, PASSWORD);
		} catch (SQLException e) {
			return DriverManager.getConnection(URL, USER, "");
		}
	}   
}         
                      	        