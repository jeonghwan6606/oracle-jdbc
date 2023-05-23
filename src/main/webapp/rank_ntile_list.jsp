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
	
	//모델 2 직원  랭크 구하는 쿼리
	/*
		select first_name, salary, rank() over(order by salary)
		from employees;
	
		select first_name, salary, dense_rank() over(order by salary)
		from employees;
		
		select first_name, salary, row_number() over(order by salary)
		from employees;

	*/
	
	String denseSql = "select 번호, first_name, salary, denseRank from (select rownum 번호, first_name, salary, denseRank from (select first_name, salary, dense_rank() over(order by salary) denseRank from employees)) WHERE 번호 between ? and ?";
	PreparedStatement denseStmt = conn.prepareStatement(denseSql);
	denseStmt.setInt(1, beginRow);
	denseStmt.setInt(2, endRow);
	
	System.out.println(denseStmt);
	
	ResultSet denseRs = denseStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> denseList
		= new ArrayList<HashMap<String, Object>>();
	while(denseRs.next()){
		HashMap<String, Object> d = new HashMap<String, Object>();
		d.put("firstName", denseRs.getString("first_name"));
		d.put("salary", denseRs.getInt("salary"));
		d.put("denseRank", denseRs.getInt("denseRank"));
			
		denseList.add(d);		
	}
	
	//row_number rank 
	String rownumSql = "select 번호, first_name, salary, rownumRank from (select rownum 번호, first_name, salary, rownumRank from (select first_name, salary, row_number() over(order by salary) rownumRank from employees)) WHERE 번호 between ? and ?";
	PreparedStatement rownumStmt = conn.prepareStatement(rownumSql);
	rownumStmt.setInt(1, beginRow);
	rownumStmt.setInt(2, endRow);
	
	System.out.println(rownumStmt);
	
	ResultSet rownumRs = rownumStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> rownumList
		= new ArrayList<HashMap<String, Object>>();
	while(rownumRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("firstName", rownumRs.getString("first_name"));
		r.put("salary", rownumRs.getInt("salary"));
		r.put("rownumRank", rownumRs.getInt("rownumRank"));
			
		rownumList.add(r);		
	}
	
	//ntile
	// select first_name, salary, sum(salary) over(), ratio_to_report(salary) over() from employees;

		String ntileSql = "select first_name, salary, salarySum, ratio from (select first_name, salary, sum(salary) over() salarySum, ratio_to_report(salary) over() ratio from employees)";
		PreparedStatement ntileStmt = conn.prepareStatement(ntileSql);

		System.out.println(ntileStmt);
		
		ResultSet ntileRs = ntileStmt.executeQuery();
		
		ArrayList<HashMap<String,Object>> ntileList
			= new ArrayList<HashMap<String, Object>>();
		while(ntileRs.next()){
			HashMap<String, Object> n = new HashMap<String, Object>();
			n.put("firstName", ntileRs.getString("first_name"));
			n.put("salary", ntileRs.getInt("salary"));
			n.put("sum", ntileRs.getInt("salarySum"));
			n.put("ratio", ntileRs.getDouble("ratio"));
				
			ntileList.add(n);		
		}
		
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>랭크함수(denseRank) </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>연봉</td>
			<td>연봉순위</td>
		</tr>
		<%
			for(HashMap<String, Object> d : denseList) {
		%>
				<tr>
					<td><%=(String)(d.get("firstName"))%></td>	
					<td><%=(Integer)(d.get("salary"))%></td>
					<td><%=(Integer)(d.get("denseRank"))%></td>	
				</tr>
		<%		
			}
		%>
	</table>
	<h3>랭크함수(rownumer) </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>연봉</td>
			<td>연봉순위</td>
		</tr>
		<%
			for(HashMap<String, Object> r : rownumList) {
		%>
				<tr>
					<td><%=(String)(r.get("firstName"))%></td>	
					<td><%=(Integer)(r.get("salary"))%></td>
					<td><%=(Integer)(r.get("rownumRank"))%></td>	
				</tr>
		<%		
			}
		%>
	</table>
		<%
			if(minPage > 1){
		%>
			<a href= "./rank_ntile_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>&nbsp;
		
		<%
			}
			for(int i = minPage; i<=maxPage; i=i+1){
				if(i== currentPage){ //현재페이지일 경우 별도의 디자인 지정
					%>
								<span  style= "background-color:yellow"><%=i%></span>
					<% 
				}else{
		%>	
					<a href= "./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 
				}
			}
			if(maxPage != lastPage){
		%>
				<a href= "./rank_ntile_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>&nbsp;
		<% 	
			}
		%>

		<h3>비율분석함수: ratio 함수 </h3>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>연봉</td>
			<td>sum</td>
			<td>ratio</td>
		</tr>
		<%
			for(HashMap<String, Object> n : ntileList) {
		%>
				<tr>
					<td><%=(String)(n.get("firstName"))%></td>	
					<td><%=(Integer)(n.get("salary"))%></td>
					<td><%=(Integer)(n.get("sum"))%></td>	
					<td><%=(Double)(n.get("ratio"))%></td>	
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>