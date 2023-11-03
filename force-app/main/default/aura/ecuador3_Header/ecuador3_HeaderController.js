({
    doInit:function(component, event, helper){
        console.log('ecu3_header')
    },
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
//     handlePRMCommunityEvent : function(cmp, event) { 
//         var message = event.getParam("message"); 
//         if (message == "Home") {
//                 document.querySelector("#search-super-d").style.display = "none";
//                 document.querySelector(".search-bar-container").style.display = "";
//                 document.querySelector("#header-extension").style.display = "none";
//                 // document.querySelector("#parent-div-search-super-m").style.display = "";
//         } else if (message == "CitizenDetail") {
//                 document.querySelector("#search-super-d").style.display = "";
//                 document.querySelector(".search-bar-container").style.display = "";
//                 document.querySelector("#header-extension").style.display = "";
//                 // document.querySelector("#parent-div-search-super-m").style.display = "";
//         } else if (message == "CitizenSearch") {
//                 document.querySelector("#search-super-d").style.display = "";
//                 document.querySelector(".search-bar-container").style.display = "";
//                 document.querySelector("#header-extension").style.display = "";
//                 // document.querySelector("#parent-div-search-super-m").style.display = "";
//         } else {
//                 document.querySelector("#search-super-d").style.display = "";
//         }
//     }
})