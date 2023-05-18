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
	
	//모델 2 직원랭크 구하는 쿼리
	/*
		select employee_id, last_name, salary, 
	   	rank() over(order by salary desc) 전체사원수 -- rank 는 정렬이 되어있어야 순위를 매긴다// 순위를 매기는 용으로 오덜바이 결과셋에는 정렬이 되지 않는다.
		from employees;
	*/
	
	String rankSql = "select 번호, employee_id, last_name, salary, 연봉순위 from (select rownum 번호, employee_id, last_name, salary, 연봉순위  from(select employee_id, last_name, salary, rank() over(order by salary desc) 연봉순위 from employees) )where 번호 between ? and ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1, beginRow);
	rankStmt.setInt(2, endRow);
	
	System.out.println(rankStmt);
	
	ResultSet rankRs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> rankList
		= new ArrayList<HashMap<String, Object>>();
	while(rankRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("employeeId", rankRs.getInt("employee_id"));
		r.put("lastName", rankRs.getString("last_name"));
		r.put("salary", rankRs.getInt("salary"));
		r.put("연봉순위", rankRs.getInt("연봉순위"));
		
		rankList.add(r);		
	}
	
	System.out.println(rankList.size()+"<--list.size()");	
		
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>분석함수(rank) </h3>
	<table border="1">
		<tr>
			<td>employeeId</td>
			<td>last_name</td>
			<td>연봉</td>
			<td>연봉순위</td>
		</tr>
		<%
			for(HashMap<String, Object> r : rankList) {
		%>
				<tr>
					<td><%=(Integer)(r.get("employeeId"))%></td>
					<td><%=(String)(r.get("lastName"))%></td>	
					<td><%=(Integer)(r.get("salary"))%></td>
					<td><%=(Integer)(r.get("연봉순위"))%></td>
					
				</tr>
		<%		
			}
		%>
	</table>
		<%
			if(minPage > 1){
		%>
			<a href= "./rankFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>&nbsp;
		<%
			}
			for(int i = minPage; i<=maxPage; i=i+1){
				if(i== currentPage){ //현재페이지일 경우 별도의 디자인 지정
					%>
								<span  style= "background-color:yellow"><%=i%></span>
					<% 
				}else{
		%>	
					<a href= "./rankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 
				}
			}
			if(maxPage != lastPage){
		%>
				<a href= "./rankFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>&nbsp;
		<% 	
			}
		%>

</body>
</html>