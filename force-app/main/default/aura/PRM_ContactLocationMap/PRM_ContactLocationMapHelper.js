({
	URL_GEOLOCATION : 'https://nominatim.openstreetmap.org/search?format=json&limit=3',
	loadMapWithAddress : function(objCitizenWrapper, arrAddressParts, intZoom, objHelper, community) {	
		var strAddress = null;
		var strUrl = null;
		var dblLatitude = null;
		var dblLongitude = null;
		var objMap = null;

		if(arrAddressParts !== undefined && arrAddressParts !== null && arrAddressParts.length > 0) {
			strAddress = arrAddressParts.join(',');
			console.log('loadMapWithAddress [strAddress : ' + strAddress + ']');

			strUrl = objHelper.URL_GEOLOCATION + '&q=\'' + strAddress + '\'';
			console.log('loadMapWithAddress [strUrl : ' + strUrl + ']');

			fetch(strUrl).then((objResponse) => objResponse.json()).then((objData) => {
				if(objData !== undefined && objData !== null && objData.length > 0) {
					console.log('loadMapWithAddress [lat : ' + objData[0].lat + ']');
					console.log('loadMapWithAddress [lon : ' + objData[0].lon + ']');

					dblLatitude  = objData[0].lat;
					dblLongitude = objData[0].lon;
			
					objMap = L.map('map', { zoomControl: false }).setView([dblLatitude, dblLongitude], intZoom);

					var CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
						// attribution: '&copy; <a href="https://comunidad.cuidarnos.app">Cuidarnos</a>',
						attribution: '&copy; ' + community,
						subdomains: 'abcd',
						maxZoom: intZoom
					}).addTo(objMap);

					L.marker([dblLatitude, dblLongitude]).addTo(objMap).bindPopup('');
				} else {
					intZoom -= 2;
					arrAddressParts = arrAddressParts.slice(1 , arrAddressParts.length); 
					objHelper.loadMapWithAddress(objCitizenWrapper, arrAddressParts, intZoom, objHelper, community);
				}
			}).catch(
				(error) => console.log('loadMapWithAddress [error : ' + error + ']')
			);
		}
	}
})