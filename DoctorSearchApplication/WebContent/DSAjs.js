var searchDocs = [];
var fv;
var apiKey = '5c53490fbdd176694ccc59ea747d1dae';
function formValues(elements) {
	this.urlEls = {
		name : elements['name'].value,
		location : encodeURIComponent(elements['lat'].value + ','
				+ elements['lng'].value + ','
				+ elements['range'].value),
		user_location : encodeURIComponent(elements['lat'].value
				+ ',' + elements['lng'].value),
		gender : elements['gender'].value,
		limit: elements['perPage'].value,
		skip: '0'
	};
	this.processEls = {
		
	};
	let s = elements['sort'].value;
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
	//console.log(data.practices);
	for (var i = 0; i < data.practices.length; i++) {
		if (data.practices[i].within_search_area)
			this.practices.push(data.practices[i]);
	}
	this.languages = data.profile.languages;
}
function checkLength(page)
{
	let docLength = searchDocs.length;
	let size = fv.urlEls.limit;
	if(docLength >= page*size)
	{
		var t = searchDocs.slice((page-1)*size, page*size);
		//console.log(t);
		makeTable(t, page);
	}
	else
	{
		let s = fv.urlEls.skip;
		fv.urlEls.skip = s+size;
		processForm(fv, page);
	}
}

function processForm(formDetails, page) {
	fv = formDetails;
	var url = 'https://api.betterdoctor.com/2016-03-01/doctors?';
	var npiurl = 'https://npiregistry.cms.hhs.gov/api/?';
	var urlkeys = Object.keys(formDetails.urlEls);
	for (var i = 0; i < urlkeys.length; i++) {
		if(formDetails.urlEls[urlkeys[i]] != '')
		{
			url += urlkeys[i] + '=' + formDetails.urlEls[urlkeys[i]] + '&';
		}
	}
	url += '&user_key=' + apiKey;
	$.ajax({
		url : url,
		type : 'GET',
		success : function(data) {
			var doctors = [];
			data.data.forEach(function(item) {
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
			Array.prototype.push.apply(searchDocs, doctors);
			//console.log(searchDocs.length);
			checkLength(page);
			/*var geocoder = new google.maps.Geocoder();
			var service = new google.maps.places.PlacesService(document.createElement('div'));
			var sumIndex = 0;
			Promise.all(doctors.map(function(doc) {
				//console.log(doc);
				return Promise.all(doc.practices.map(function(prac, index) {
					//console.log(prac);
					let latlng = {
						lat : parseFloat(prac.lat),
						lng : parseFloat(prac.lon)
					};
					let delay = 200*(index+sumIndex);
					let l = doc.practices.length;
					if(index == l-1) sumIndex += l;
					console.log(delay + ', ' + sumIndex +', ' + l);
					return new Promise(function(resolve, reject) {
						setTimeout(function(){
							geocoder.geocode({
							'location' : latlng
						}, function(results, status) {
							if (status === google.maps.GeocoderStatus.OK) {
								if (results[0]) {
									service.getDetails({placeId: results[0].place_id}, function(place, status){
										if (status === google.maps.places.PlacesServiceStatus.OK) {
											console.log(place);
											resolve(place.opening_hours);
										}
									});
								} else {
									reject();
								}
							} else {
								window.alert('Geocoder failed due to: ' + status);
							}
						});
						}, delay);
					});
				})).then(function(hours){
					doc.hours = hours;
					//console.log('here');
				});
			})).then(function(){
				//console.log('here 2');
				
			});*/
		},
		error : function(data) {
			alert(data.meta.message)
		}
	});
}
function makeTable(array, pageNum) {
	var tableText, paganText;
	if (array.length == 0)
		tableText = "There are no results matching that criteria.";
	else {
		tableText = "<table class='table table-bordered table-condensed'><thead><tr><th>Name</th></tr></thead><tbody>";
		for (var i = 0; i < array.length; i++) {
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
		if (pageNum <= 3) {
			start = 1;
			stop = 5;
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
			paganText += "<a href='#' onclick='checkLength(" + i + ");'>" + i
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
		// initializes the popovers
		$(function() {
			$('[rel="popover"]').popover({
				html : true
			});
		});
		document.getElementById("myPagan").innerHTML = paganText;
	}
	document.getElementById("myTable").innerHTML = tableText;

}