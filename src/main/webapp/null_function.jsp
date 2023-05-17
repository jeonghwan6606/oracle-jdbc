<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	/*
	select 이름, nvl(일분기, 0) from 실적;
	select 이름, nvl2(일분기, 'success', 'fail') from 실적;
	select 이름, nullif(사분기, 100) from 실적;
	select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적;
	*/
		
	String nvlSql = "select 이름, nvl(일분기, 0) 일분기 from 실적";
	PreparedStatement nvlStmt = conn.prepareStatement(nvlSql);
	
	System.out.println(nvlStmt);
	
	ResultSet nvlRs = nvlStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> nvlList
		= new ArrayList<HashMap<String, Object>>();
	while(nvlRs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("name", nvlRs.getString("이름"));
		n.put("one", nvlRs.getInt("일분기"));
				
		nvlList.add(n);		
	}
	
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') one_success from 실적";
	PreparedStatement nvl2Stmt = conn.prepareStatement(nvl2Sql);
	
	System.out.println(nvl2Stmt);
	
	ResultSet nvl2Rs = nvl2Stmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> nvl2List
		= new ArrayList<HashMap<String, Object>>();
	while(nvl2Rs.next()){
		HashMap<String, Object> n2 = new HashMap<String, Object>();
		n2.put("name", nvl2Rs.getString("이름"));
		n2.put("oneSuccess", nvl2Rs.getString("one_success"));
				
		nvl2List.add(n2);		
	}
	
	String nullIfSql = "select 이름, nullif(사분기, 100) 사분기 from 실적";
	PreparedStatement nullIfStmt = conn.prepareStatement(nullIfSql);
	
	System.out.println(nullIfStmt);
	
	ResultSet nullIfRs = nullIfStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> nullIfList
		= new ArrayList<HashMap<String, Object>>();
	while(nullIfRs.next()){
		HashMap<String, Object> nI = new HashMap<String, Object>();
		nI.put("name", nullIfRs.getString("이름"));
		nI.put("four", nullIfRs.getInt("사분기"));
				
		nullIfList.add(nI);		
	}
	
	String coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) coalesce from 실적";
	PreparedStatement coalesceStmt = conn.prepareStatement(coalesceSql);
	
	System.out.println(coalesceStmt);
	
	ResultSet coalesceRs = coalesceStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> coalesceList
		= new ArrayList<HashMap<String, Object>>();
	while(coalesceRs.next()){
		HashMap<String, Object> c = new HashMap<String, Object>();
		c.put("name", coalesceRs.getString("이름"));
		c.put("coalesce", coalesceRs.getInt("coalesce"));
		
				
		coalesceList.add(c);		
	}
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>oracle null 함수(nvl) </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>일분기</td>
		</tr>
		<%
			for(HashMap<String, Object> n : nvlList) {
		%>
				<tr>
					<td><%=(String)(n.get("name"))%></td>
					<td><%=(Integer)(n.get("one"))%></td>		
				</tr>
		<%		
			}
		%>
	</table>
	<h3>oracle null 함수(nvl2) </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>일분기</td>
		</tr>
		<%
			for(HashMap<String, Object> n2 : nvl2List) {
		%>
				<tr>
					<td><%=(String)(n2.get("name"))%></td>
					<td><%=(String)(n2.get("oneSuccess"))%></td>		
				</tr>
		<%		
			}
		%>
	</table>
	<h3>oracle null 함수(nullIf) </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>사분기</td>
		</tr>
		<%
			for(HashMap<String, Object> nI : nullIfList) {  
		%>
				<tr>
					<td><%=(String)(nI.get("name"))%></td>
					<td><%=(Integer)(nI.get("four"))%></td>		
				</tr>
		<%		
			}
		%>
	</table>
	
	<h3>oracle null 함수(coalesce) </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>coalesce</td>
		</tr>
		<%
			for(HashMap<String, Object> c : coalesceList) {
		%>
				<tr>
					<td><%=(String)(c.get("name"))%></td>
					<td><%=(Integer)(c.get("coalesce"))%></td>		
				</tr>
		<%		
			}
		%>
	</table>
	
</body>
</html>