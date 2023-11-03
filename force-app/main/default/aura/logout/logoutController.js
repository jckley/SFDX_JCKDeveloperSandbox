({
	doInit : function(component, event, helper) {
		var baseUrl = window.location;
        window.location.replace("/secur/logout.jsp?retUrl=https%3A%2F%2F" + baseUrl +"%2Flogin");
	}
})