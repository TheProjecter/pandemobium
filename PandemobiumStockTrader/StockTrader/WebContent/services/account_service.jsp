<%--
 * Pandemobium Stock Trader is a mobile app for Android and iPhone with 
 * vulnerabilities included for security testing purposes.
 * Copyright (c) 2011 Denim Group, Ltd. All rights reserved worldwide.
 *
 * This file is part of Pandemobium Stock Trader.
 *
 * Pandemobium Stock Trader is free software: you can redistribute it 
 * and/or modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Pandemobium Stock Trader.  If not, see
 * <http://www.gnu.org/licenses/>.
--%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="com.denimgroup.stocktrader.ConnectionManager,java.sql.ResultSet,
			java.sql.Connection, java.sql.SQLException, java.sql.Statement"%>
<%
    response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader ("Expires", 0); //prevent caching at the proxy server
	String method = request.getParameter("method");
	if(method == null || method.equals("")){
		System.out.println("No method provided");
	}
	else{
		Connection c = ConnectionManager.getManager().getConnection();
		if(c!= null){
			Statement s = c.createStatement();
			if(method.equals("getAccountId")){
				ResultSet rs = null;
				String username = request.getParameter("username");
				String password = request.getParameter("password");
				//There is not enough validation allowing sql to be injected as 
				//username and password values			
				if(username != null && !username.equals("")) {
					//	Actually got a non-blank username so try to log in
					String query = "SELECT * FROM logins WHERE username = '" + username + "' AND password = '" + password + "'";
					System.out.println("About to execute query: " + query);
					try{
						rs = s.executeQuery(query);
						if(rs.next()){
							out.println("account_id="+rs.getString("id"));
						}else{
							out.println("error: unknown username or password");
						}
					}catch(Exception e){
						System.err.println(e);
						out.println(e);
					}
				}else{
					 out.println("error: unknown username");
				}
			}else{
				out.println("Unknown method " + method);
			}
			try{
				c.close();
			}catch(Exception e){};
		}else{
			out.println("error: database communication failed");
		}
	}
%>