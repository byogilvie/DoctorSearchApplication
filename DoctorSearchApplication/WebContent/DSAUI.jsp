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
<div class='row'>
<div class="form-group">
<div class='col-md-8 col-mid-offset-2'>
  <label for="myInput">Search for doctor (if nothing is entered, then it will show all results)</label>
  <input type="text" class="form-control" id="myInput">
  <button type="button" class="btn" onClick="makeTable()">
  	<span class="glyphicon glyphicon-search"></span>search</button>
</div>
</div>
</div>
<div class ='row' id='myTable'></div>
</div>
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
	//creates the table
	function makeTable()
	{
		var input = document.getElementById("myInput").value;
		var tempTable, text, i, j;
		//checks to see you values in original table match the search input
		if(input === undefined)
			tempTable = doctors;
		else
			{
			tempTable = [];
		for(i = 0; i < docLength; i++)
		{
			var array = $.map(doctors[i], function(value, index) {
			    return [value];
			});
			for(j = 0; j < array.length; j++)
			{
				var tempvar = array[j];
				if(tempvar.indexOf(input) != -1)
				{
					tempTable.push(doctors[i]);
					break;
				}			
			}
		}
			}
		if(tempTable.length == 0) text = "There are no results matching that criteria.";
		else
		{
			text = "<table class='table table-bordered'><thead><tr><th>Name</th></tr></thead><tbody>";
			for(i = 0; i < tempTable.length; i++)
			{
				var popoverContent = "<p><ul><li>" + tempTable[i].Name + "</li><li>" + tempTable[i].email + "</li></ul></p>";
				text += "<tr><td><a href='#' data-trigger='focus' rel='popover' title='"+tempTable[i].Name+"'data-content='"+popoverContent+"'>"+tempTable[i].Name+"</a></td></tr>";
			}
			text += "</tbody></table>";
		}
		//initializes the popovers
		$(function(){
		    $('[rel="popover"]').popover({html:true});   
		});
		document.getElementById("myTable").innerHTML = text;
	}
</script>
</body>
</html>