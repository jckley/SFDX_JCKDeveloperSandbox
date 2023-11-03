({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        console.log('riverTAAAB');
        objComponent.find('home').getElement().classList.remove("slds-is-active");
        objComponent.find('citizens').getElement().classList.remove("slds-is-active");
        objComponent.find('territories').getElement().classList.remove("slds-is-active");
        objComponent.find('encuestas').getElement().classList.remove("slds-is-active");
        //objComponent.find('iframe').getElement().classList.remove("slds-is-active");
        // objComponent.find('change').getElement().classList.remove("slds-is-active");
        // objComponent.find('dashboard').getElement().classList.remove("slds-is-active");

        var urlString = window.location.href;
        var pageURL = urlString.substring(urlString.indexOf("/s/")+2);

        // console.log('pageURL: ' + pageURL);

        if(pageURL==='/'){
            objComponent.find('home').getElement().classList.add("slds-is-active");
        } else if(pageURL.includes('global-search') || pageURL.includes('contact') || pageURL.includes('citizen-list')){
            objComponent.find('citizens').getElement().classList.add("slds-is-active");
        } else if(pageURL.includes('territories') || pageURL.includes('territorio-administrativo')){
            objComponent.find('territories').getElement().classList.add("slds-is-active");
        } else if(pageURL.includes('encuestas')){
            objComponent.find('encuestas').getElement().classList.add("slds-is-active");
        // } else if(pageURL.includes('cambiar-perfil-usuario')){
        //     objComponent.find('change').getElement().classList.add("slds-is-active");
        // } else if(pageURL.includes('dashboard')){
        //     objComponent.find('dashboard').getElement().classList.add("slds-is-active");
        }
        //else if(pageURL.includes('iframe')){
        //    objComponent.find('iframe').getElement().classList.add("slds-is-active");
        //}


    },
    home : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL +"/s/");
    },
    globalSearch : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL +"/s/citizen-list");
    },
    territories : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL +"/s/territories");
    },
    encuestas : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL +"/s/encuestas");
    },
    // changeProfile : function(component, event, helper) {
    //     var urlString = window.location.href;
    //     var baseURL = urlString.substring(0, urlString.indexOf("/s"));
    //     window.location.replace(baseURL +"/s/cambiar-perfil-usuario");
    // },
    dashboard : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL +"/s/dashboard");
    },
    iframe : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL +"/s/iframe");
    },
})