package com.fairpay;

import java.sql.*;

public class TestDB {
    public static void main(String[] args) throws Exception {
        Class.forName("org.postgresql.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/fairpay_db", "postgres", "postgres");
        
        DatabaseMetaData meta = conn.getMetaData();
        System.out.println("Driver name: " + meta.getDriverName());
        System.out.println("Driver version: " + meta.getDriverVersion());
        System.out.println("Database product version: " + meta.getDatabaseProductVersion());
        conn.close();
    }
}
