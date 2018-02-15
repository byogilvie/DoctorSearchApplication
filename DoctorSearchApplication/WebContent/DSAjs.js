function formValues(elements) {
	this.urlEls = {
		name : elements.namedItem('name').value,
		location : encodeURIComponent(elements.namedItem('lat').value + ','
				+ elements.namedItem('lng').value + ','
				+ elements.namedItem('range').value),
		user_location : encodeURIComponent(elements.namedItem('lat').value
				+ ',' + elements.namedItem('lng').value)
	};
	this.processEls = {
		gender : elements.namedItem('gender').value
	};
	let s = elements.namedItem('sort').value;
	if (s != '') {
		if (s == 'clicks')
			this.processEls.sort = s;
		else
			this.urlEls.sort = s;
	}
}
function loopThrough(array, target) {
	var text = '<ul><li>';
	for (var i = 0; i < array.length; i++) {
		text += array[i][target] + '</li>';
		if (i != array.length - 1) {
			text += '<li>';
			continue;
		}
	}
	text += '</ul>';
	return text;
}
var hours;
function doctor(data) {
	this.name = data.profile.first_name + " " + data.profile.last_name;
	this.uid = data.uid;
	this.gender = data.profile.gender;
	let temp = JSON.parse(localStorage.getItem(data.uid));
	if (temp) {
		this.clicks = temp.length;
	} else {
		this.clicks = 0;
		let users = [];
		localStorage.setItem(data.uid, JSON.stringify(users));
	}
	this.specialties = data.specialties;
	this.practices = [];
	for (var i = 0; i < data.practices.length; i++) {
		if (data.practices[i].within_search_area)
			this.practices.push(data.practices[i]);
	}
	this.languages = data.profile.languages;
}
function processData(array) {
	Promise.all(array.map(function(item) {
		return Promise.all(item.practices.map(function(pract) {
			if (pract.within_search_area) {
				return getWorkingHours(pract.lat, pract.lng);
			} else
				return;
		}));
	})).then(function(data) {
		hours = data;
		nextProcess(array);
	});
}
function nextProcess(array, formDetails) {
	var doctors = [];
	array.forEach(function(item) {
		var doc = new doctor(item);
		doctors.push(doc);
	});
	var keys = Object.keys(formDetails.processEls);
	for (var i = 0; i < keys.length; i++) {
		if (keys[i] == 'sort' || formDetails.processEls[keys[i]] == '')
			continue;
		doctors = doctors.filter(function(item) {
			return item[keys[i]] == formDetails.processEls[keys[i]];
		});
	}
	if (formDetails.processEls.sort == 'clicks') {
		doctors.sort(function(a, b) {
			var x = a.clicks;
			var y = b.clicks;
			if (x > y)
				return -1;
			if (y < x)
				return 1
			return 0;
		});
	}
	makeTable(doctors, 1);
}
function getWorkingHours(latitude, longitude) {
	var geocoder = new google.maps.Geocoder;
	var service = new google.maps.places.PlacesService(document
			.createElement('div'));
	var latlng = {
		lat : parseFloat(latitude),
		lng : parseFloat(longitude)
	};
	return new Promise(
			function(resolve, reject) {
				geocoder
						.geocode(
								{
									'location' : latlng
								},
								function(results, status) {
									if (status === google.maps.GeocoderStatus.OK) {
										if (results[1]) {
											console.log('here');
											service
													.getDetails(
															'{placeId: '
																	+ results[1].place_id
																	+ '}',
															callback);
											function callback(place, status) {
												if (status == google.maps.places.PlacesServiceStatus.OK) {

													resolve(place.opening_hours);
												}
											}
										}
									}
								});
			});
}
function makeTable(array, pageNum) {

	var tableText, paganText;
	if (array.length == 0)
		tableText = "There are no results matching that criteria.";
	else {
		var perPage = $('#perPage').val();
		var end;
		if ((pageNum) * perPage >= array.length)
			end = array.length;
		else
			end = (pageNum) * perPage;
		tableText = "<table class='table table-bordered table-condensed'><thead><tr><th>Name</th></tr></thead><tbody>";
		for (var i = (pageNum - 1) * perPage; i < end; i++) {
			var doc = array[i];
			var popoverContent = "<p><ul><li>Name: " + doc.name
					+ "</li><li>Gender: " + doc.gender
					+ "</li><li>Specialties: "
					+ loopThrough(doc.specialties, 'name')
					+ "</li><li>Languages: "
					+ loopThrough(doc.languages, "name")
					+ "</li><li>Users Clicked: " + doc.clicks
					+ "</li></ul></p>";
			tableText += "<tr><td><a href='javascript://' id='" + doc.uid
					+ "' data-trigger='focus' rel='popover' title='" + doc.name
					+ "'data-content='" + popoverContent + "'>" + doc.name
					+ "</a></td></tr>";
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
			paganText += "<a href='#' onclick='makeTable(" + i + ");'>" + i
					+ "</a></li>";
		}
		paganText += "</ul>";
		$('body').on('click', '[rel="popover"]', function() {
			var idNum = $(this).attr('id');
			var usersClicked = JSON.parse(localStorage.getItem(idNum));
			var user = localStorage.getItem('activeUser');
			if (!usersClicked.includes(user)) {
				usersClicked.push(user);
				localStorage.setItem(idNum, JSON.stringify(usersClicked));
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