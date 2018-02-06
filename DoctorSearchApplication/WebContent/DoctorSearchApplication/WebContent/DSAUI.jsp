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
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCnA5Xj0yd3O1xJKlwluq8BYmuQnKuVCFY&libraries=places">
<script type="text/javascript">
	$(window).on('load', function() {
		if(localStorage.getItem('clickedList') == null)
		{
			let clickedList = [];
			localStorage.setItem('clickedList', JSON.stringify(clickedList));
		}
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
				<form>
					<label><b>First Name</b></label> <input type="text" id="fName"
						required> <label><b>Last Name</b></label> <input
						type="text" id="lName" required> <label><b>email</b></label>
					<input type="email" name="email" required>
					<button type="submit" id='loginForm'>Log In</button>
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
				<div class='col-md-4 col-sm-4'>
					<label for="name">Name</label> <input type="text"
						class="form-control" id="name">
				</div>
			</div>
			<div class="form-group row">
				<div class='col-md-2 col-sm-4'>
					<label for="city">City</label> <input type="text"
						class="form-control" id="city">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="state">State</label> <input type="text"
						class="form-control" id="state" maxlength="2">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="zip">Postal Code</label> <input type="number"
						class="form-control" id="zip" maxlength="5">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="range">Search range</label> <input type="number"
						class="form-control" id="range" step='5' min='5' max='25'
						value='5'>
				</div>
			</div>
			<div class="form-group row">
				<div class='col-md-2 col-sm-4'>
					<label for="gender">Gender</label> <select id="gender">
						<option value=""></option>
						<option value="male">Male</option>
						<option value="female">Female</option>
					</select>
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="perPage">Results per page</label> <input type="number"
						class="form-control" id="perPage" step='10' min='10' max='100'
						value='10'>
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="sortEl">Sort by:</label> <select id="sortEl">
						<option value=""></option>
						<option value='full-name-asc'>Name</option>
						<option value='distance-asc'>Distance</option>
						<option value='clicks'>Clicks</option>
					</select>
				</div>
				<div class='col-md-4 col-sm-4'>
					<label><input type="checkbox" class="form-control"
						id="newPatients" value=''>Accepting new patients</label>
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for='query'>Language</label> <input type="text"
						class="form-control" id="query">
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="service">Type of service:</label> <select id="service">
						<option value=""></option>
						<option value='medical'>Medical</option>
						<option value='therapy'>Therapy</option>
						<option value='vision'>Vision</option>
						<option value='dental'>Dental</option>
					</select>
				</div>
			</div>
			<!--  
			<div class='form-group row'>
				<div class='col-md-4 col-sm-4'>
					<label><input type="checkbox" class="form-control"
						id="timeSearch" value=''>Search by working hours:</label>
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for='open'>Open before:</label> <input type='time' id='open'
						class='form-control'>
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for='close'>Close after:</label> <input type='time'
						id='close' class='form-control'>
				</div>
				<div class='col-md-2 col-sm-4'>
					<label for="days">Day(s):</label> <select id="days">
						<option value="0,1,2,3,4,5,6">All week</option>
						<option value='1,2,3,4,5'>Weekdays</option>
						<option value='0,6'>Weekend</option>
						<option value='0'>Sunday</option>
						<option value='1'>Monday</option>
						<option value='2'>Tuesday</option>
						<option value='3'>Wednsday</option>
						<option value='4'>Thursday</option>
						<option value='5'>Friday</option>
						<option value='6'>Saturday</option>
					</select>
				</div>
			</div>
			-->
			<button type="button" class="btn" id="searchDocs">
				<span class="glyphicon glyphicon-search"></span>search
			</button>
		</form>
		<!--  <button type="button" class="btn" id="topClicked">Top ten clicked doctors</button> -->
		<div class='row' id='myTable'></div>
		<div id='myPagan'></div>
		<!-- This part is part of the terms of using their data -->
		<p>
			Data from <a href='https://betterdoctor.com'>BetterDoctor</a>
		</p>
	</div>
	<script>
		function logOut() {
			localStorage.removeItem("activeUser");
			//console.log(localStorage.getItem('activeUser'));
			$('#loginModal').modal('show');
		}
		$('#loginForm').click(function(){
			//console.log($('#fName').val() + " " + $('#lName').val());
			localStorage.setItem('activeUser', $('#fName').val() + " "
					+ $('#lName').val());
			$('#loginModal').modal('hide');
		});
		
		var resultcount, searchResults, locationTxt = '', sortEl;
		var apiKey = '5c53490fbdd176694ccc59ea747d1dae';
		//creates the table
		/**$('#topClicked').click(function(){
			let clickedList = JSON.parse(localStorage.getItem('clickedList'));
			let topDocs = [];
			for(var i = 0; i < 10; i++)
			{
				jQuery.ajax({
			        url: 'https://api.betterdoctor.com/2016-03-01/doctors/'+ clickedList[i] + '?user_key=' + apiKey,
			        success: function (result) {
			            topDocs.push[result.data];
			        },
			        async: false
			    });
			}
			searchResults = topDocs;
			resultcount = 10;
			makeTable(1);
		});*/
		$('#searchDocs').click(function(){
			//gets the address
			var geocoder = new google.maps.Geocoder();
			var address = $('#city').val()+", "+$('#state').val()+" "+$('#zip').val();
			if(address == ',  ')
				nextSteps();
			var lat, lng;
			geocoder.geocode({'address': address}, function(results, status) {
		          if (status === 'OK') {
		              lat = results[0].geometry.location.lat();
		        	  lng = results[0].geometry.location.lng();
		        	  locationTxt = lat + ','+lng;
		        	  nextSteps();
		            }
			});
			
		});
		
		//this is needed because the geocoder is an asynchronous call
		function nextSteps()
		{
			var url = 'https://api.betterdoctor.com/2016-03-01/doctors?';
			var npiurl = 'https://npiregistry.cms.hhs.gov/api/?';
			sortEl = $('#sortEl').val();
			//gets the name
			url += 'name=' + encodeURI($('#name').val()) + '&';
			url += 'location='+encodeURIComponent(locationTxt+','+$('#range').val()) + '&';
			url += 'user_location='+encodeURIComponent(locationTxt) + '&';
			if(sortEl != "" && sortEl != 'clicks')
			{
				url += 'sort=' + sortEl + '&';
			}
			var gender = $('#gender').val();
			if(gender != '') url += 'gender='+gender+'&';
			var query = $('#query').val();
			if(query != '') url += 'query='+query+'&';
			url += 'limit=100&user_key=' + apiKey;
			$.get(url, function(data){
				nextProcess(data.data);
				
				});
		}
		function loopThrough(array, target)
		{
			var text = '<ul><li>';
			for(var i = 0; i < array.length; i++)
			{
				text += array[i][target] +'</li>';
				if(i != array.length-1)
				{
					text += '<li>';
					continue;
				}
			}
			text += '</ul>';
			return text;
		}
		function updateClickedRanking()
		{
			let clickedList = JSON.parse(localStorage.getItem('clickedList'));
			clickedList.sort(function(a, b)
				{
				var x = JSON.parse(localStorage.getItem(a)).length;
				var y = JSON.parse(localStorage.getItem(b)).length;
				if(x > y) return -1;
				if(x < y) return 1;
				return 0;
				
				});
			localStorage.setItem('clickedList', JSON.stringify(clickedList));
		}
		var hours;
		
		function processData(array)
		{
			
			
			Promise.all(array.map(function(item){
							return Promise.all(item.practices.map(function(pract){
								if(pract.within_search_area)
								{
									return getWorkingHours(pract.lat, pract.lng);
								}
								else return;
							}));					
						})).then(function(data){
							hours = data;
							nextProcess(array);
						});
		}
		function nextProcess(array)
			{		
			
			let tempArray = [];
			let clickedList = JSON.parse(localStorage.getItem('clickedList'));
			array.forEach(function(item){
				let usersClicked = localStorage.getItem(item.uid);
				if(usersClicked == null)
				{
					let users = [];
					clickedList.push(item.uid);
					localStorage.setItem(item.uid, JSON.stringify(users));
				}
			});
			localStorage.setItem('clickedList', JSON.stringify(clickedList));
			if(sortEl == 'clicks')
			{
				array.sort(function(a, b)
						{
							var x = clickedList.indexOf(a.uid);
							var y = clickedList.indexOf(b.uid);
							if(x > y) return 1;
							if(x < y) return -1;
							return 0;
						});
				
			}
			var service = $('#service').val();
			//var searchTime = $('#searchTime').val();
			var newPatients = $('#newPatients').val();
			if(service == '' && !newPatients)
			{
				tempArray = array;
			}
			else
			{
			array.forEach(function(item, index){
					var checkIfTrue = [];
					if(newPatients)
					{
						let clear = false;
						item.practices.forEach(function(item2){
						if(item2.within_search_area && item2.accepts_new_patients)
						{
							clear = true;
							return;
						}
						
					});
						checkIfTrue.push(clear);
					}
						/**if(searchTime)
						{
							let clear = false;
							var open = $('#open').val(), close = $('#close').val(), days = ($('#day').val()).split(',');
							var practHours = hours[index];
							item.practices.forEach(j, function(item2){	
								if(item2.within_search_area)
								{	
								if(practHours[j].period[Number(d)].open.time < open && practHours[j].period[Number(d)].close.time > close)
								{
									clear = true;
									return;
								}	
							}
							});
							checkIfTrue.push(clear);
						}*/
					if(service != '')
					{
						let clear = false
						item.specialties.forEach(function(item2){
							if(service == item2.category)
							{
								clear = true;
								return;
							}
						});
						checkIfTrue.push(clear);
					}
					if(!checkIfTrue.includes(false))
					{
						tempArray.push(item);
					}
					else hours.remove(index);
				});			
			}
			searchResults = tempArray;
			resultcount = searchResults.length;
			makeTable(1);
		}
		function getWorkingHours(latitude, longitude)
		{
			var geocoder = new google.maps.Geocoder;
			var service = new google.maps.places.PlacesService(document.createElement('div'));
			var latlng = {lat: parseFloat(latitude), lng: parseFloat(longitude)};
			return new Promise(function(resolve, reject){
				geocoder.geocode({'location': latlng}, function(results, status) {
				    if (status === google.maps.GeocoderStatus.OK) {
				      if (results[1])
				    	  {
				    	  console.log('here');
				    	  	 service.getDetails('{placeId: '+results[1].place_id+'}', callback);
				    	  	 function callback(place, status)
				    	  	 {
				    	  		if (status == google.maps.places.PlacesServiceStatus.OK) {
				    	  			
				    	  		    resolve(place.opening_hours);
				    	  		  }
				    	  	 }
				    	  }
				    	  }
			});
			});	
			}
		function makeTable(pageNum) {
			
			var tableText, paganText;
			if (resultcount == 0)
				tableText = "There are no results matching that criteria.";
			else {
				var perPage = $('#perPage').val();
				var end;
				if ((pageNum) * perPage >= resultcount)
					end = resultcount;
				else
					end = (pageNum) * perPage;
				tableText = "<table class='table table-bordered table-condensed'><thead><tr><th>Name</th></tr></thead><tbody>";
				for (var i = (pageNum-1)*perPage; i < end; i++) {
					var doc = searchResults[i];
					var popoverContent = "<p><ul><li>Name: "+ doc.profile.first_name + " " + doc.profile.last_name
					+"</li><li>Gender: "+doc.profile.gender
					+"</li><li>Specialties: " + loopThrough(doc.specialties, 'name') 
					+ "</li><li>Languages: " +loopThrough(doc.profile.languages, "name")
					+"</li><li>Users Clicked: "+JSON.parse(localStorage.getItem(doc.uid)).length
					+"</li></ul></p>";
					tableText += "<tr><td><a href='javascript://' id='"+doc.uid+"' data-trigger='focus' rel='popover' title='"+doc.profile.first_name+"'data-content='"+popoverContent+"'>"
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
				$('body').on('click', '[rel="popover"]', function()
						{
							var idNum = $(this).attr('id');
							var usersClicked = JSON.parse(localStorage.getItem(idNum));
							var user = localStorage.getItem('activeUser');
							if(!usersClicked.includes(user))
								{
									usersClicked.push(user);
									localStorage.setItem(idNum, JSON.stringify(usersClicked));
									updateClickedRanking();
								}
						});
				//initializes the popovers
				$(function() {
					$('[rel="popover"]').popover({
						html : true
					});
				});
				document.getElementById("myPagan").innerHTML = paganText;
			}
			document.getElementById("myTable").innerHTML = tableText;
			
		}
	</script>
</body>
</html>