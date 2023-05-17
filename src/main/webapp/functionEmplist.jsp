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
	
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); //index 1사용
	}
	
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1)*rowPerPage+1;
	int endRow = beginRow + (rowPerPage-1);
	if(endRow> totalRow){
		endRow = totalRow;
	}
	
	
	/*

 	Select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
    
    from
        (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자  , 
        salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees)
    where 번호 between 1 and 10;   
	
	*/	
	
	
	String sql = "Select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자  , salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees)where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	
	System.out.println(stmt);
	
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> empList
		= new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> e  = new HashMap<String, Object>();
		
		e.put("번호", rs.getInt("번호"));
		e.put("이름", rs.getString("이름"));
		e.put("이름첫글자", rs.getString("이름첫글자"));
		e.put("연봉", rs.getInt("연봉"));
		e.put("급여", rs.getDouble("급여"));
		e.put("입사날짜", rs.getString("입사날짜"));
		e.put("입사년도", rs.getInt("입사년도"));
				
		empList.add(e);		
	}

	System.out.println(empList.size()+"<--list.size()");		


%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table border = "1">
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>첫글자</td>
			<td>연봉</td>
			<td>급여</td>
			<td>입사날짜</td>
			<td>입사년도</td>
		</tr>
		<%
			for(HashMap<String,Object> m : empList){
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(String)m.get("이름첫글자") %></td>
					<td><%=(Integer)m.get("연봉")%></td>
					<td><%=(Double)m.get("급여")%></td>
					<td><%=(String)m.get("입사날짜")%></td>
					<td><%=(Integer)m.get("입사년도")%></td>
				</tr>
		<%
			}
		%>
	</table>
	<%
		//페이지 네비게이션 페이징 
		int pagePerPage = 10;
		/*(cp-1)/ paperPerPage * paperPage+1 --> minPage
		minPage + (pagePerPage-1) --> maxPage
		maxPage > lastPage --> maxPage = lastPage
		*/	
		
		int lastPage = totalRow / rowPerPage;
		if(totalRow%rowPerPage != 0){
			lastPage = lastPage + 1;
		}
		
		//페이지 네비게이션 페이징 
		int minPage = (((currentPage-1)/pagePerPage)*pagePerPage) +1;
		int maxPage = minPage + (pagePerPage-1);
		if(maxPage > lastPage){
			maxPage = lastPage;
		}
		
		if(minPage > 1){

	%>	
		<a href= "./functionEmplist.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>&nbsp;
	<% 	
			
		}
		
		for(int i = minPage; i<=maxPage; i=i+1){
			if(i== currentPage){
				%>
							<span><%=i%></span>
				<% 
			}else{
	%>	
				<a href= "./functionEmplist.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
	<% 
			}
		}
		
		if(maxPage != lastPage){
	%>
		<a href= "./functionEmplist.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>&nbsp;
	<% 	
		}
	%>

</body>
</html>