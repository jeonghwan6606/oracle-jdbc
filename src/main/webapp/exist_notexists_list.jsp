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
	
	//모델 2 exist, notexists 쿼리
	/*
		select e.employee_id, e.first_name
		from employees e 
		where exists (select * from departments d
		                where d.department_id = e.department_id);
		                                   
		select e.employee_id, e.first_name
		from employees e 
		where not exists (select * from departments d
		                where d.department_id = e.department_id);

	*/
	
	String existSql = "select 번호, employee_id, first_name from (select rownum 번호, e.employee_id, e.first_name from employees e where exists (select * from departments d where d.department_id = e.department_id)) where 번호 between ? and ?";
	PreparedStatement existStmt = conn.prepareStatement(existSql);
	existStmt.setInt(1, beginRow);
	existStmt.setInt(2, endRow);
	
	System.out.println(existStmt);
	
	ResultSet existRs = existStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> existList
		= new ArrayList<HashMap<String, Object>>();
	while(existRs.next()){
		HashMap<String, Object> e = new HashMap<String, Object>();
		e.put("employeeId", existRs.getInt("employee_id"));
		e.put("firstName", existRs.getString("first_name"));
			
		existList.add(e);		
	}
	
	//not existSql
	String notExistSql = "select employee_id, first_name from(select e.employee_id, e.first_name from employees e where not exists (select * from departments d where d.department_id = e.department_id))";
	PreparedStatement notExistStmt = conn.prepareStatement(notExistSql);

	
	System.out.println(notExistStmt);
	
	ResultSet notExistRs = notExistStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> notExistList
		= new ArrayList<HashMap<String, Object>>();
	while(notExistRs.next()){
		HashMap<String, Object> ne = new HashMap<String, Object>();
		ne.put("employeeId", notExistRs.getInt("employee_id"));
		ne.put("firstName", notExistRs.getString("first_name"));
			
		notExistList.add(ne);		
	}
		
		
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>exist 연산자 </h3>
	<table border="1">
		<tr>
			<td>employeeId</td>
			<td>이름</td>
		</tr>
		<%
			for(HashMap<String, Object> e : existList) {
		%>
				<tr>
					<td><%=(Integer)(e.get("employeeId"))%></td>	
					<td><%=(String)(e.get("firstName"))%></td>
				</tr>
		<%		
			}
		%>
	</table>
		<%
			if(minPage > 1){
		%>
			<a href= "./exist_notexists_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>&nbsp;
		
		<%
			}
			for(int i = minPage; i<=maxPage; i=i+1){
				if(i== currentPage){ //현재페이지일 경우 별도의 디자인 지정
					%>
								<span  style= "background-color:yellow"><%=i%></span>
					<% 
				}else{
		%>	
					<a href= "./exist_notexists_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 
				}
			}
			if(maxPage != lastPage){
		%>
				<a href= "./exist_notexists_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>&nbsp;
		<% 	
			}
		%>

	<h3>not exist 연산자 </h3>
	<table border="1">
		<tr>
			<td>employeeId</td>
			<td>이름</td>
		</tr>
		<%
			for(HashMap<String, Object> ne : notExistList) {
		%>
				<tr>
					<td><%=(Integer)(ne.get("employeeId"))%></td>	
					<td><%=(String)(ne.get("firstName"))%></td>
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>