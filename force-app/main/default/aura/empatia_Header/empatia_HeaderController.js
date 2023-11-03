({
    home : function(component, event, helper) {
            var urlString = window.location.href;
            var baseURL = urlString.substring(0, urlString.indexOf("/s"));
            window.location.replace(baseURL +"/s/");
    },
    logout : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL + "/secur/logout.jsp?retUrl=https%3A%2F%2F" + baseURL +"/s/login/");
    },
})