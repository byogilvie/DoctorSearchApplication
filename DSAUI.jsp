<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>DSA Main Page</title>
<link href='dist/css/bootstrap.min.css' rel='stylesheet'>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script type="text/javascript" src="dist/js/bootstrap.js"></script>
<script type="text/javascript">
$(window).on('load',function(){
	//if not logged in already, show modal
	if(localStorage.getItem('activeUser'))
		return;
	else
	{
		$('#loginModal').modal('show');
	}
});
</script>
</head>
<body>
<div class="modal fade" id="loginModal" data-backdrop="static">
<div class='modal-content'>
<div class='modal-body'>
	<form onSubmit="return validateLogin(this);">
		<label><b>First Name</b></label>
		<input type="text" name="fName" required>
		<label><b>Last Name</b></label>
		<input type="text" name="lName" required>
		<label><b>email</b></label>
		<input type="email" name="email" required>
		<button type="submit">Log In</button>
			</form>
			</div>
			</div>
</div>
<div class='container'>
<div class='row'>
	<button type='button' class='btn' onClick='logOut()'>Log Out</button>
</div>
<form class='well'>
<div class="form-group row">
<div class='col-md-2 col-sm-4'>
  <label for="fName">First Name</label>
  <input type="text" class="form-control" id="fName">
  </div>
  <div class='col-md-2 col-sm-4'>
  <label for="lName">Last Name</label>
  <input type="text" class="form-control" id="lName">
</div>
</div>
<!--  
<div class="form-group row">
<div class='col-md-2 col-sm-4'>
  <label for="city">City</label>
  <input type="text" class="form-control" id="city">
  </div>
  <div class='col-md-2 col-sm-4'>
  <label for="state">State</label>
  <input type="text" class="form-control" id="state" >
</div>
</div>-->
<button type="button" class="btn" id="searchDocs">
  	<span class="glyphicon glyphicon-search"></span>search</button>
</form>
</div>
<div class ='row' id='myTable'></div>

<script>
function validateLogin(myForm)
{
	localStorage.setItem('activeUser', myForm.fName + " " + myForm.lName);
	$('#loginModal').modal('hide');
}
function logOut()
{
	localStorage.removeItem("activeUser");
	//console.log(localStorage.getItem('activeUser'));
	$('#loginModal').modal('show');
}
	var doctors, docLength;
	//small list of names to start with
	doctors = [{Name:"John Doe", email:"john@example.com"}, 
		{Name:"Mary Moe", email:"mary@example.com"}, 
		{Name:"July Dooley", email:"july@example.com"}];
	
	
	docLength = doctors.length; 
	
	var resultcount, searchResults;
	//creates the table
	$(document).ready(function(){
		$('#searchDocs').click(function(){
			var fName = $('#fName').val();
			var lName = $('#lName').val();
			//here's the part that makes the request
			var request = new XMLHttpRequest();
		    var url = "https://npiregistry.cms.hhs.gov/api/?first_name="+fName+"&last_name="+lName;
		    request.onreadystatechange = function() {
		      if (request.readyState === 4 && request.status === 200) {
		        var response = JSON.parse(request.responseText);
		        resultcount = response.result_count;
		        searchResults = response.results;
		        //response.addHeader("Access-Control-Allow-Origin", "*");
		        makeTable(response);
		      }
		    }
		    request.open("GET", url, true);
		    request.send();
		});	
	});
	function sortTable(sortEl)
	{
		searchResults.sort(function(a, b)
				{
			var x = a[sortEl].toLowerCase();
	        var y = b[sortEl].toLowerCase();
	        if (x < y) {return -1;}
	        if (x > y) {return 1;}
	        return 0;
				});
		makeTable(1);
	}
	function makeTable(pageNum)
	{
		var text;
		if(resultcount == 0) text = "There are no results matching that criteria.";
		else
		{
			var perPage = $('#perPage').val();
			var end;
			if((pageNum)*perPage >= resultcount) end = resultcount;
			else end = (pageNum)*perPage;
			text = "<table class='table table-bordered'><thead><tr><th>Name</th></tr></thead><tbody>";
			for(var i = ((pageNum-1)*perPage); i < end; i++)
			{
				var popoverContent = "<p><ul><li>" + searchResults[i].basic.first_name + " " + searchResults[i].basic.last_name + "</li><li>" + searchResults[i].number + "</li></ul></p>";
				text += "<tr><td><a href='#' data-trigger='focus' rel='popover' title='"+searchResults[i].Name+"'data-content='"+popoverContent+"'>"+searchResults[i].Name+"</a></td></tr>";
			}
			text += "</tbody></table><br>";
			var start, stop;
			var max = Math.ceil(resultcount/perPage);
			if(pageNum <= 3)
			{
				start = 1;
				stop = 5;
			}
			else if(pageNum >= (max-2))
			{
				start = max-5;
				stop = max;
			}
			else
			{
				start = pageNum-2;
				stop = pageNum+2;
			}
			text += "<ul class='pagination'>";
			for(var i = start; i <= stop; i++)
			{
				if(i==pageNum)
				{
					text += "<li class='active'>";
				}
				else text += "<li>";
				text += "<a href='#'>"+i+"</a></li>";
			}
			text += "</ul>";
		}
		//initializes the popovers
		$(function(){
		    $('[rel="popover"]').popover({html:true});   
		});
		document.getElementById("myTable").innerHTML = text;
	}
	//$('ul.pagination li a').on('click', makeTable());
</script>
</body>
</html>