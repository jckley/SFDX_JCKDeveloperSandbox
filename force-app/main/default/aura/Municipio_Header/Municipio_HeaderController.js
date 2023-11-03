({
	logout : function(objComponent, objEvent, objHelper) {
        var strUrl = null;
        
        strUrl = objComponent.get('v.url');
        window.location.href =  '/s/login';
	},
    
    changeIconsHover : function(objComponent, objEvent, objHelper) {
        var imgIconWhite = document.getElementById('icon-white');
        var imgIconGray = document.getElementById('icon-gray');
        
        imgIconWhite = document.getElementById('icon-white');
        imgIconGray = document.getElementById('icon-gray');
		
        imgIconWhite.classList.add('slds-hide');
        imgIconGray.classList.remove('slds-hide');
    }
})