package com.denimgroup.stocktrader;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

/*
 * This class will handle getting the database connection
 * and building the tables as needed.
 */

public class ConnectionManager {
	
	private static ConnectionManager manager;
	
	public static synchronized ConnectionManager getManager(){
		if(manager == null)
			manager = new ConnectionManager();
		return manager;
	}
	
	public synchronized Connection getConnection(){
		return getHSQLDBConnection();
	}
	
	private ConnectionManager(){
		init();
	}
	
	private void init(){
		Connection connection = getHSQLDBConnection();
		if(connection != null){
			if(!testTables(connection)){
				buildTables(connection);
			}
		}else{
			System.err.println("Unable to get database connection");
		}
	}
	
	//returns the connection to our database
	private Connection getHSQLDBConnection(){
		Connection c = null;
		try{
			Class.forName("org.hsqldb.jdbcDriver").newInstance();
			c = DriverManager.getConnection("jdbc:hsqldb:mem:stocktrader", "sa", "");
		}catch(Exception e){
			System.err.println(e);
		}
		return c;
	}
	
	/* Tests if the tables have been created
	 * @param Connection database connection object
	 */
	private boolean testTables(Connection conn){
		try{
			Statement s = conn.createStatement();
			s.execute("select count(*) from  tips");
			return true;
		}catch(Exception e){
		}
	    return false;
	}
	
	/* Creates the tables needed
	 * @param Connection database connection object
	 */
	public void buildTables(Connection conn){
		try{
			System.out.println("About to set up database for exercises");
			Statement s = conn.createStatement();
			s.execute("CREATE TABLE tips (id IDENTITY, tip_creator INT, symbol VARCHAR(64), target_price REAL, reason VARCHAR(64))");
			s.execute("CREATE TABLE trades (id IDENTITY, symbol VARCHAR(64), quantity INT, price_per REAL)");
			s.execute("CREATE TABLE logins (id IDENTITY, username VARCHAR(32), password VARCHAR(32))");
			s.execute("INSERT INTO logins (username, password) VALUES ('dcornell', 'danpass')");
			s.execute("INSERT INTO logins (username, password) VALUES ('jdoe', 'janejohn')");
		}catch(Exception e){
			System.err.println(e);
		}
	    System.out.println("Finished setting up database for exercises");
	}
	
	
}
