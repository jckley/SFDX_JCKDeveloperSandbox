({
	logout : function(component, event, helper) {
        var baseUrl = window.location;
        window.location.replace("/secur/logout.jsp?retUrl=https%3A%2F%2F" + baseUrl +"%2Flogin");
        //window.location.href = '/ucr/s/login';
	},
    
    changeIconsHover : function(component, event, helper) {
        var iconWhite = document.getElementById('icon-white');
        var iconGray = document.getElementById('icon-gray');
		iconWhite.classList.add('slds-hide');
        iconGray.classList.remove('slds-hide');
    },
})