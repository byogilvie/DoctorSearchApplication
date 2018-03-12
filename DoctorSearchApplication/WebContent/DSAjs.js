/* global Promise */
var searchDocs = [];
var providers;
var fv, max;
var apiKey = '5c53490fbdd176694ccc59ea747d1dae';
function formValues(urlEls, processEls, url, key, isPract) {
    this.urlEls = urlEls;
    this.processEls = processEls;
    this.url = url;
    this.user_key = key;
    this.isPract = isPract;
    this.makeUrl = function ()
    {
        let urltext = this.url;
        var urlkeys = Object.keys(this.urlEls);
        for (var i = 0; i < urlkeys.length; i++) {
            if (this.urlEls[urlkeys[i]] != '')
            {
                urltext += urlkeys[i] + '=' + encodeURIComponent(this.urlEls[urlkeys[i]]) + '&';
            }
        }
        urltext += 'user_key=' + this.user_key;
        return urltext;
    }
}
function buildInsuranceList()
{
    $.ajax({
        url: "https://api.betterdoctor.com/2016-03-01/insurances?user_key=" + apiKey,
        type: 'GET',
        success: function (data)
        {
            providers = data.data;
            let text = "";
            providers.forEach(function (p) {
                text += '<option value=' + p.uid + '>' + p.name + "</option>";
            });
            document.getElementById("insurance").innerHTML = text;
        },
        error: function (data) {
            alert(data.meta.message)
        }
    });
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
function doctor(practices, profile, specialties, insurances, uid) {
    this.name = profile.first_name + " " + profile.last_name;
    this.uid = uid;
    this.gender = profile.gender;
    this.bio = profile.bio;
    let temp = JSON.parse(localStorage.getItem(uid));
    if (temp) {
        this.clicks = temp.length;
    } else {
        this.clicks = 0;
        let users = [];
        localStorage.setItem(uid, JSON.stringify(users));
    }
    this.specialties = specialties;
    this.practices = practices;
    this.insurances = insurances;
    this.languages = profile.languages;
    this.practHours = [];
    this.practHoursText = [];
    this.makeTable = function ()
    {
        var tText = '<ul>Practices:';
        // console.log(this.practHoursText.length);
        for (var i = 0; i < this.practices.length; i++)
        {
            tText += '<li>Name: ' + this.practices[i].name
                    + '</li>';
            tText += '<li>Open Hours: not available</li>';
            /*
            if (this.practHoursText[i] == 'Opening hours not available')
                tText += '<li>Open Hours: not available</li>';
            else
            {
                tText += '<ul>Open Hours:';
                for (var j = 0; j < this.practHoursText[i].length; j++)
                {
                    tText += '<li>' + this.practHoursText[i][j] + '</li>';
                }
                tText += '</ul>';
            }
            */
        }
        tText += '</ul>';
        return tText;
    };
    this.contains = function(variables, name, subname)
    {
    	let thisVar = this[name];
    	if(!Array.isArray(variables))
    	{
    		return variables == thisVar;
    	}
    	let isArr = false;
    	if(Array.isArray(thisVar)) isArr = true;
    	for(var i = 0; i < variables.length; i++)
    	{
    		let temp = variables[i];
    		if(isArr)
    		{
    			for(var j = 0; j < thisVar.length; j++)
    			{
    				let t;
    	    		if(subname == '') t = thisVar[j];
    	    		else t = thisVar[j][subname];
    				if(t.includes(temp)) return true;
    			}
    		}
    		else if(thisVar.includes(temp)) return true;
    	}
    	return false;
    };
}

function createForm(elements)
{
	console.log(elements['newPatients'].checked);
    let s = elements['sort'].value;
    let u = 'https://api.betterdoctor.com/2016-03-01/';
    var p;
    var processEls = {
    		specialties: [elements['specialties'].value]
    };
    var urlEls =
            {
                location: elements['lat'].value + ','
                        + elements['lng'].value + ','
                        + elements['range'].value,
                user_location: elements['lat'].value
                        + ',' + elements['lng'].value,
                limit: elements['perPage'].value,
                skip: '0'
            };
    if(elements['newPatients'].checked)
	{
		processEls.practices = [true];
	}
    var result = $('#insurance').val();
    var insuranceText = '';
    if (result.length > 0)
    {
        for (var i = 0; i < result.length; i++)
        {
            var insurance = providers.find(function (ins) {
                return ins.uid == result[i];
            });
            for (var j = 0; j < insurance.plans.length; j++)
            {
                insuranceText += insurance.plans[j].uid;
                if (i != result.length - 1 || j != insurance.plans.length - 1)
                    insuranceText += ',';
            }
        }
    }
    if (elements['practName'].value != '')
    {
        u += 'practices?';
        p = true;
        urlEls.name = elements['practName'].value;
        processEls.name = elements['docName'].value;
        processEls.gender = elements['gender'].value;
        processEls.insurances = insuranceText.split(',');
        processEs.bio = elements['language'].value;
        if (s != '')
            processEls.sort = s;
    } else
    {
        u += 'doctors?';
        p = false;
        urlEls.name = elements['docName'].value;
        urlEls.gender = elements['gender'].value;
        urlEls.insurance_uid = insuranceText;
        urlEls.query = elements['language'].value;
        if (s != '') {
            if (s == 'clicks')
                processEls.sort = s;
            else
                urlEls.sort = s;
        }
    }
    return new formValues(urlEls, processEls, u, apiKey, p);
}
function startSearch(formDets)
{
    var formDetails = createForm(formDets);
    fv = formDetails;
    searchDocs.length = 0;
    processForm(formDetails, 1);
}
function checkLength(page)
{
	console.log('here')
    let docLength = searchDocs.length;
    let size = fv.urlEls.limit;
    let s = fv.urlEls.skip;
    if (docLength >= page * size || s + size > max)
    {
        let upwardBound;
        if (docLength < page * size)
            upwardBound = docLength;
        else
            upwardBound = page * size;
        var t = searchDocs.slice((page - 1) * size, upwardBound);
        makeTable(t, page);
    } else
    {
        fv.urlEls.skip = s + size;
        processForm(fv, page);
    }
}
function connectUIDsToPlans(uids)
{
    var results = [];
    providers.forEach(function (item) {
        item.plans.forEach(function (plan) {
            if (uids.includes(plan.uid))
                results.push({name: plan.name, uid: plan.uid});
        });
    });
    return results;
}
function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
function getWorkingHours(latlng)
{
    var geocoder = new google.maps.Geocoder;
    var service = new google.maps.places.PlacesService(document.createElement('div'));
    return new Promise(function (resolve, reject) {
        geocoder.geocode({
            'location': latlng
        }, function (results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
                if (results[0]) {
                    service.getDetails({placeId: results[0].place_id}, function (place, status) {
                        if (status === google.maps.places.PlacesServiceStatus.OK) {
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
    });
}
function processForm(formDetails, page) {
    var u = formDetails.makeUrl();
    $.ajax({
        url: u,
        type: 'GET',
        success: function (data) {
            max = data.meta.total;
            var doctors = [];
            if (formDetails.isPract)
            {
                data.data.forEach(function (item) {
                    let ins = connectUIDsToPlans(item.insurance_uids);
                    item.doctors.forEach(function (d)
                    {
                        var doc = new doctor([item], d.profile,
                                d.specialties, ins, d.uid);
                        doctors.push(doc);
                    });
                });
            } else
            {
                data.data.forEach(function (item) {
                    let ins = [];
                    item.insurances.forEach(function (i) {
                        ins.push({name: i.insurance_plan.name, uid: i.insurance_plan.uid});
                    });
                    var doc = new doctor(item.practices, item.profile,
                            item.specialties, ins, item.uid);
                    doctors.push(doc);
                });
            }
            //doctors = doctors.filter(function(item) { return item.practices.length > 0; });
            
            /*for(var i = 0; i<doctors.length; i++){
                let doc = doctors[i];
                for(var j = 0; j < doc.practices.length; j++) {
                    let prac = doc.practices[j];
                    let latlng = {
                        lat: parseFloat(prac.lat),
                        lng: parseFloat(prac.lon)
                    };
                    await timeout(200);
                    await getWorkingHours(latlng).then(function(hours){
                        let temp = ["Opening hours not available"];
                        if (typeof hours != 'undefined')
                        {
                            doc.practHours.push(hours.periods);
                            doc.practHoursText.push(hours.weekday_text);
                        } else
                        {
                            doc.practHours.push(temp);
                            doc.practHoursText.push(temp);
                        }
                    });
                }
            }*/
                var keys = Object.keys(formDetails.processEls);
                for (var i = 0; i < keys.length; i++) {
                	let sub = '';
                    if (keys[i] == 'sort' || formDetails.processEls[keys[i]] == '')
                        continue;
                    if(keys[i] == 'insurances') sub = 'uid';
                	if(keys[i] == 'specialties') sub = 'name';
                	if(key[i] == 'practices') sub = 'accepts_new_patients';
                    doctors = doctors.filter(function (item) {
                        return item.contains(formDetails.processEls[keys[i]], keys[i], sub);
                    });
                }
                /*if(formDetails.isPract && formDetails.processEls.insurance_uid[0] != '')
                {
                    doctors = doctors.filter(function(item){
                        for(var i = 0; i < item.insurances.length; i++)
                        {
                            let ins = item.insurances[i];
                            if(formDetails.processEls.insurance_uid.includes(ins.uid))
                                return true;
                        }
                        return false;
                    });
                }*/
                if(formDetails.processEls.sort == 'clicks') {
                    doctors.sort(function (a, b) {
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
                checkLength(page);
        },
        error: function (data) {
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
                    + "</li><li>" + doc.makeTable()
                    + "</li><li>Specialties: "
                    + loopThrough(doc.specialties, 'name')
                    + "</li><li>insurances: "
                    + loopThrough(doc.insurances, "name")
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
        $('body').on('click', '[rel="popover"]', function () {
            var idNum = $(this).attr('id');
            var usersClicked = JSON.parse(localStorage.getItem(idNum));
            var user = localStorage.getItem('activeUser');
            if (!usersClicked.includes(user)) {
                usersClicked.push(user);
                localStorage.setItem(idNum, JSON.stringify(usersClicked));
            }
        });
        // initializes the popovers
        $(function () {
            $('[rel="popover"]').popover({
                html: true
            });
        });
        document.getElementById("myPagan").innerHTML = paganText;
    }
    document.getElementById("myTable").innerHTML = tableText;

}