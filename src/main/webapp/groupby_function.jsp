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
	
	String groupingSql = "select department_id, job_id, count(*) from employees group by grouping sets(department_id,job_id)";
	PreparedStatement groupingStmt = conn.prepareStatement(groupingSql);
	
	System.out.println(groupingStmt);
	
	ResultSet groupingRs = groupingStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> groupingList
	 = new ArrayList<HashMap<String, Object>>();
	while(groupingRs.next()){
		HashMap<String, Object> g = new HashMap<String, Object>();
		g.put("departmentId", groupingRs.getInt("department_id"));
		g.put("jobId", groupingRs.getString("job_id"));
		g.put("employeeCnt",groupingRs.getInt("count(*)"));
		
		groupingList.add(g);		
	}
	
	String rollupSql = "select department_id, job_id, count(*) from employees group by rollup(department_id,job_id)";
	PreparedStatement rollupStmt = conn.prepareStatement(rollupSql);
	
	System.out.println(rollupStmt);
	
	ResultSet rollupRs = rollupStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> rollupList
	 = new ArrayList<HashMap<String, Object>>();
	while(rollupRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("departmentId", rollupRs.getInt("department_id"));
		r.put("jobId", rollupRs.getString("job_id"));
		r.put("employeeCnt",rollupRs.getInt("count(*)"));
		
		groupingList.add(r);		
	}
	
	String cubeSql = "select department_id, job_id, count(*) from employees group by cube(department_id,job_id)";
	PreparedStatement cubeStmt = conn.prepareStatement(cubeSql);
	
	System.out.println(cubeStmt);
	
	ResultSet cubeRs = cubeStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> cubeList
	 	= new ArrayList<HashMap<String, Object>>();
	while(cubeRs.next()){
		HashMap<String, Object> c = new HashMap<String, Object>();
		c.put("departmentId", cubeRs.getInt("department_id"));
		c.put("jobId", cubeRs.getString("job_id"));
		c.put("employeeCnt",cubeRs.getInt("count(*)"));
		
		groupingList.add(c);		
	}
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Employees table GROUP BY 확장함수(grouping sets) </h1>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>jobId</td>
			<td>인원수</td>
		</tr>
		<%
			for(HashMap<String, Object> g : groupingList) {
		%>
				<tr>
					<td><%=(Integer)(g.get("departmentId"))%></td>
					<td><%=(String)(g.get("jobId"))%></td>
					<td><%=(Integer)(g.get("employeeCnt"))%></td>
				</tr>
		<%		
			}
		%>
	</table>
	
	<h1>Employees table GROUP BY 확장함수(rollup) </h1>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>jobId</td>
			<td>인원수</td>
		</tr>
		<%
			for(HashMap<String, Object> r : groupingList) {
		%>
				<tr>
					<td><%=(Integer)(r.get("departmentId"))%></td>
					<td><%=(String)(r.get("jobId"))%></td>
					<td><%=(Integer)(r.get("employeeCnt"))%></td>
				</tr>
		<%		
			}
		%>
	</table>
	
	<h1>Employees table GROUP BY 확장함수(cube) </h1>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>jobId</td>
			<td>인원수</td>
		</tr>
		<%
			for(HashMap<String, Object> c : groupingList) {
		%>
				<tr>
					<td><%=(Integer)(c.get("departmentId"))%></td>
					<td><%=(String)(c.get("jobId"))%></td>
					<td><%=(Integer)(c.get("employeeCnt"))%></td>
				</tr>
		<%		
			}
		%>
	</table>
	
</body>
</html>