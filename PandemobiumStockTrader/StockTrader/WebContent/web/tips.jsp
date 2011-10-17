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

<%@ page	language="java"
			contentType="text/html; charset=ISO-8859-1"
    		pageEncoding="UTF-8"%>

<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*,javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>
<%@ page import="org.xml.sax.*" %>
<%@ page import="com.denimgroup.stocktrader.ConnectionManager" %>
<%@page import="com.denimgroup.stocktrader.YahooFinanceUtility"%>



<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Tips Page</title>
<script type="text/javascript">
function clickButton() {
	var symbol = document.getElementById('symbolField').value;
	document.getElementById('sendTips').action = "sendtips://SHARE?symbol=" + symbol;
	document.getElementById('sendTips').submit();
}
</script>
</head>
<body>
	<p> 
	Welcome to the Tips page! 
	You can use this page to view tips posted by other Stock Trader users to advise which stocks to purchase and when.   
	</p>
	<p>
		<table>
			<thead>
				<tr>
					<th>User</th><th>Stock</th><th>Current Price</th><th>Target Price</th><th>TRADE!</th>
				</tr>
			</thead>	
			<%
				String BASE_QUERY, BASE_URL, SERVICE, STORE, retVal = null;
				String current_price = "0";
				BASE_QUERY = "select Ask from yahoo.finance.quotes where symbol = ";
				BASE_URL = "http://query.yahooapis.com/";
				SERVICE = "v1/public/yql";
				STORE = "store://datatables.org/alltableswithkeys";
				String yahoo_query, fullUrl;
				Statement s = null;
				ResultSet res = null;
				Connection conn = ConnectionManager.getManager().getConnection();
				if (conn != null) {
					s = conn.createStatement();
					String query = "select logins.username, tips.symbol, tips.target_price, tips.reason from tips, logins where (logins.id = tips.tip_creator)";
					System.out.println("\nQuery is: " + query);
					res = s.executeQuery(query);
				
				while (res.next()) {
					try {
						String symbol = res.getString("symbol").toUpperCase();
						System.out.println("symbol: " + symbol);
						
						//get current stock value
						//current_price = YahooFinanceUtility.getQuoteForSymbol(symbol);
						
						yahoo_query = BASE_QUERY + "\"" + symbol + "\"";
						fullUrl = BASE_URL + SERVICE + "?q="
								+ URLEncoder.encode(yahoo_query) + "&env=" + STORE;
							URL url = new URL(fullUrl);
						URLConnection urlConn = url.openConnection();
						DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory
								.newInstance();
						DocumentBuilder docBuilder = docBuilderFactory
								.newDocumentBuilder();
						Document doc = docBuilder.parse(urlConn.getInputStream());
							doc.getDocumentElement().normalize();
						System.out.println("Root element of the doc is "
								+ doc.getDocumentElement().getNodeName());
						NodeList listOfNodes = doc.getElementsByTagName("results");
						Node firstNode = listOfNodes.item(0);
						System.out.println("1: " + firstNode.getNodeName());
							Element nextElement = (Element) firstNode;
						NodeList nextList = nextElement.getChildNodes();
						System.out.println("2: "
								+ ((Node) nextList.item(0)).getNodeName());
							Node thirdNode = nextList.item(0);
						Element thirdElement = (Element) thirdNode;
						NodeList thirdList = thirdElement.getChildNodes();
						Node lastNode = thirdList.item(0);
						current_price = lastNode.getTextContent();
						System.out.println("3: " + lastNode.getTextContent());
						System.out.println("3: " + lastNode.getNodeName());
					} catch (Exception e) {
						e.printStackTrace();
					}
			%>
			<tr>
				<td><%=res.getString("username")%></td>
				<td><%=res.getString("symbol")%></td>
				<td><%=current_price%></td>
				<td><%=res.getString("target_price")%></td>
				<td>
					<a href="trade://BUY?symbol=<%=res.getString("symbol")%>&shares=50&price=<%=current_price%>">Buy 50!</a>
					<a href="trade://BUY?symbol=<%=res.getString("symbol")%>&shares=100&price=<%=current_price%>">Buy 100!</a>
				</td>
				<td><%=res.getString("reason")%></td>
			</tr>	
		<%}%>	<!--  end while -->
		</table>
	</p>
	 <p>
	 Don't be stingy!  Click here to share your tips!
	</p>
	<%
		String query2 = "SELECT DISTINCT symbol from tips ";
		System.out.println("\nQuery is: " + query2);
		ResultSet res2 = s.executeQuery(query2);
		while (res2.next()) {
	%>	
		<p>
			<a href="sendtips://SHARE?symbol=<%=res2.getString("symbol")%>">Share your tips for <%=res2.getString("symbol")%></a><br />	    
	<%
	  	}
	  	try {
	  		if(conn != null)
	  			conn.close();
	  	} catch (Exception e) {};
	  	}else{ 
	  		System.err.println("Tips could not get a valid database connection.");
	  		out.println("A communication error has occurred");
	  	}
	%>
		</p>
		
	<FORM id="sendTips" ACTION="" METHOD="GET">
		Share your tips for other symbols: &nbsp; <input id="symbolField" name="symbol" type="text"> &nbsp; <INPUT type="button" value="Submit" onclick="clickButton();"/><INPUT style="display: none;" TYPE="SUBMIT" value="Submit">		
		<br />
	</FORM>
</body>
</html>

