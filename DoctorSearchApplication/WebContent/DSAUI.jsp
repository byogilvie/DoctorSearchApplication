<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>DSA Main Page</title>
<link href='dist/css/bootstrap.min.css' rel='stylesheet'>
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script type="text/javascript" src="dist/js/bootstrap.js"></script>
<script type="text/javascript">
	$(window).on('load', function() {
		//if not logged in already, show modal
		if (localStorage.getItem('activeUser'))
			return;
		else {
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
					<label><b>First Name</b></label> <input type="text" name="fName"
						required> <label><b>Last Name</b></label> <input
						type="text" name="lName" required> <label><b>email</b></label>
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
		<form class='well' id='searchForm'>
			<div class="form-group row">
				<div class='col-md-2 col-sm-4'>
					<label for="first_name">First Name</label>
					<input type="text" class="form-control" id="first_name">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="last_name">Last Name</label>
				    <input type="text" class="form-control" id="last_name">
				</div>
			</div>
			<div class="form-group row">
				<div class='col-md-2 col-sm-4'>
					<label for="city">City</label>
					<input type="text" class="form-control" id="city">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="state">State</label>
					<input type="text" class="form-control" id="state" maxlength="2">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="zip">Postal Code</label>
					<input type="number" class="form-control" id="zip" maxlength="5">
				</div>
			</div>
			<div class="form-group row">
				<div class='col-md-2 col-sm-4'>
					<label for="gender">Gender</label>
				    <select id="gender">
				    	<option value=""></option>
				    	<option value="male">Male</option>
				    	<option value="female">Female</option>
				    </select>
				    </div>
				    <div class='col-md-2 col-sm-4'>
					<label for="perPage">Results per page</label>
					<input type="number" class="form-control" id="perPage" step='10' min='10' max='100' value='10'>
				
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="sortEl">Sort by:</label>
				    <select id="sortEl">
				    	<option value=""></option>
				    	<option value='{"details": ["profile", "last_name"]}'>Name</option>
				    </select>
				</div>
			</div>
			<button type="button" class="btn" id="searchDocs">
				<span class="glyphicon glyphicon-search"></span>search
			</button>
		</form>
		<div class='row' id='myTable'></div>
		<div id='myPagan'></div>
	</div>
	<script>
		function validateLogin(myForm) {
			localStorage.setItem('activeUser', myForm.fName + " "
					+ myForm.lName);
			$('#loginModal').modal('hide');
		}
		function logOut() {
			localStorage.removeItem("activeUser");
			//console.log(localStorage.getItem('activeUser'));
			$('#loginModal').modal('show');
		}
		
		
		var resultcount, searchResults;
		//creates the table
		$('#searchDocs').click(function(){
			var apiKey = '5c53490fbdd176694ccc59ea747d1dae';
			var url = 'https://api.betterdoctor.com/2016-03-01/doctors?';
			var npiurl = 'https://npiregistry.cms.hhs.gov/api/?';
			var sortEl = JSON.parse($('#sortEl').val());
			console.log(sortEl);
			$('#searchForm').find('input').each(function(){
				url += $(this).attr('id') + '=' + $(this).val() + '&';
			});
			url += 'limit=100&user_key=' + apiKey;
			$.get(url, function(data){
				searchResults = data.data;
				resultcount = data.meta.total;
				if(sortEl != "")
				{
					searchResults.sort(function(a, b) {
						var x = a[sortEl.details[0]][sortEl.details[1]].toLowerCase();
						var y = b[sortEl.details[0]][sortEl.details[1]].toLowerCase();
						if (x < y) {
							return -1;
						}
						if (x > y) {
							return 1;
						}
						return 0;
					});
				}
				
				makeTable(1);
				});
		});
		$('[rel="popover"]').click(function()
		{
			console.log('here');
			var idNum = $(this).attr('id');
			var usersClicked = JSON.parse(localStorage.getItem(idNum));
			var user = localStorage.getItem('activeUser');
			console.log(user + ", " + usersClicked.length);
			if(usersClicked)
			{
				if(!usersClicked.contains(user))
				{
					usersClicked.push(user);
				}
			}
			else
			{
				var users = [user];
				localStorage.setItem(idNum, JSON.stringify(users));
			}
		});
		
		function loopThrough(array, target)
		{
			var text = '';
			for(var i = 0; i < array.length; i++)
			{
				text += array[i][target];
				if(i != array.length-1)
				{
					text += ', ';
					continue;
				}
			}
			return text;
		}
		function makeTable(pageNum) {
			var tableText, paganText;
			if (resultcount == 0)
				text = "There are no results matching that criteria.";
			else {
				var perPage = $('#perPage').val();
				var end;
				if ((pageNum) * perPage >= resultcount)
					end = resultcount;
				else
					end = (pageNum) * perPage;
				tableText = "<table class='table table-bordered table-condensed'><thead><tr><th>Name</th></tr></thead><tbody>";
				for (var i = (pageNum-1)*perPage; i < (pageNum)*perPage; i++) {
					var doc = searchResults[i];
					var popoverContent = "<p><ul><li>Name: "+ doc.profile.first_name + " " + doc.profile.last_name
					+"</li><li>Gender: "+doc.profile.gender
					+"</li><li>Specialties: " + loopThrough(doc.specialties, 'name') 
					+ "</li><li>Languages: " +loopThrough(doc.profile.languages, "name") 
					+"</li></ul></p>";
					console.log(doc.uid);
					tableText += "<tr><td><a href='#' id='"+doc.uid+"' data-trigger='focus' rel='popover' title='"+doc.profile.first_name+"'data-content='"+popoverContent+"'>"
							+ doc.profile.first_name + " "+doc.profile.last_name+"</a></td></tr>";
				}
				tableText += "</tbody></table><br>";
				var start, stop;
				var max = Math.ceil(resultcount / perPage);
				if (pageNum <= 3) {
					start = 1;
					stop = 5;
				} else if (pageNum >= (max - 2)) {
					start = max - 5;
					stop = max;
				} else {
					start = pageNum - 2;
					stop = pageNum + 2;
				}
				paganText = "<ul class='pagination' id='pagan'>";
				for (var i = start; i <= stop; i++) {
					if (i == pageNum) {
						paganText += "<li class='active'>";
					} else
						paganText += "<li>";
						paganText += "<a href='#' onclick='makeTable("+i+");'>" + i + "</a></li>";
				}
				paganText += "</ul>";
			}
			//initializes the popovers
			$(function() {
				$('[rel="popover"]').popover({
					html : true
				});
			});
			document.getElementById("myTable").innerHTML = tableText;
			document.getElementById("myPagan").innerHTML = paganText;
		}
	</script>
</body>
</html>