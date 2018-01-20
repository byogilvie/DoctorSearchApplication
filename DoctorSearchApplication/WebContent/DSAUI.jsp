<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>DSA Main Page</title>
<link href='dist/css/bootstrap.min.css' rel='stylesheet'>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
</head>
<body>
<div class='container'>
<div class="form-group">
<div class='col-md-8 col-mid-offset-2'>
  <label for="myInput">Search for doctor</label>
  <input type="text" class="form-control" id="myInput">
  <button type="button" class="btn" onClick="makeTable()">search</button>
</div>
</div>
<table class="table table-bordered" id='myTable'>
    
  </table>
</div>
<script>
	var doctors, docLength;
	doctors = [{Name:"John Doe", email:"john@example.com"}, 
		{Name:"Mary Moe", email:"mary@example.com"}, 
		{Name:"July Dooley", email:"july@example.com"}];
	
	
	docLength = doctors.length;
	function makeTable()
	{
		var input = document.getElementById("myInput").value;
		console.log(input);
		var tempTable, text, i, j;
		if(input === undefined)
			tempTable == doctors;
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
			text = "<thead><tr><th>Name</th><th>Email</th></tr></thead><tbody >";
			for(i = 0; i < tempTable.length; i++)
			{
				text += "<tr><td>" + tempTable[i].Name + "</td><td>" + tempTable[i].email + "</td></tr>";
			}
			text += "</tbody>";
		}
		document.getElementById("myTable").innerHTML = text;
	}
</script>
</body>
</html>