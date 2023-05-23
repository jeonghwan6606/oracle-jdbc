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
	
	
	//모델 1 페이징
	//전체 행수 구하는 쿼리
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); //index 1사용
	}
	
	//쿼런트 페이지 가져오기
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	//rowperPage 및 시작행 끝나는 행 구하고 끝나는 행이 전체행보다 커지면(rowperPage를 더하고 1을 뻇을때) endrow는 totalrow와 같게
	int rowPerPage = 10;
	int beginRow = (currentPage-1)*rowPerPage+1;
	int endRow = beginRow + (rowPerPage-1);
	if(endRow> totalRow){
		endRow = totalRow;
	}
	
	//페이지 네비게이션 페이징 
	int pagePerPage = 10; //페이지마다 10쪽의 papagerPage
	int lastPage = totalRow / rowPerPage; // 마지막페이지는 전체행 수 나누기 페이지마다 행수 , 0으로 안나누어지면 +1 추가
	if(totalRow%rowPerPage != 0){
			lastPage = lastPage + 1;
	}
			
	//페이징 알고리즘에 따라 minPage 및 maxPage 정의 		
	int minPage = (((currentPage-1)/pagePerPage)*pagePerPage) +1; 
	int maxPage = minPage + (pagePerPage-1);
	if(maxPage > lastPage){ //마지막 페이지보다 maxPage가 클경우 라스트페이지와 같게 설정 (다음 버튼 생성 조건에 필요)
			maxPage = lastPage;
	}
	
	//모델 2 start with 쿼리
	/*
	select level, lpad(' ', level-1) || first_name, manager_id,
        sys_connect_by_path(first_name, '-')
	from employees start with manager_id is null connect by prior employee_id = manager_id;
	*/
	
	String startWithSql = "select level, lpad(' ', level-1) || first_name firstName, manager_id, sys_connect_by_path(first_name, '-') path from employees start with manager_id is null connect by prior employee_id = manager_id";
	PreparedStatement startWithStmt = conn.prepareStatement(startWithSql);
	
	System.out.println(startWithStmt);
	
	ResultSet startWithRs = startWithStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> startWithList
		= new ArrayList<HashMap<String, Object>>();
	while(startWithRs.next()){
		HashMap<String, Object> s = new HashMap<String, Object>();
		s.put("level", startWithRs.getInt("level"));
		s.put("firstName", startWithRs.getString("firstName"));
		s.put("managerId", startWithRs.getString("manager_id"));
		s.put("path", startWithRs.getString("path"));	
		startWithList.add(s);		
	}

		
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>startwith 연산자 </h3>
	<table border="1">
		<tr>
			<td>employeeId</td>
			<td>이름</td>
			<td>managerId</td>
			<td>path</td>
		</tr>
		<%
			for(HashMap<String, Object> s : startWithList) {
		%>
				<tr>
					<td><%=(Integer)(s.get("employeeId"))%></td>	
					<td><%=(String)(s.get("firstName"))%></td>
					<td><%=(String)(s.get("managerId"))%></td>
					<td><%=(String)(s.get("path"))%></td>
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>