({
    doTagSelected_CSSClasses : function(cmp) {
        var homeMenu = cmp.find('home');
        var citizenMenu = cmp.find('citizens');
        var territoriesMenu = cmp.find('territories');
        var dashboardMenu = cmp.find('dashboard');
        
        if (homeMenu) homeMenu.getElement().classList.remove("slds-is-active");
        if (citizenMenu) citizenMenu.getElement().classList.remove("slds-is-active");
        if (territoriesMenu) territoriesMenu.getElement().classList.remove("slds-is-active");
        if (dashboardMenu) dashboardMenu.getElement().classList.remove("slds-is-active");
        
        var urlString = window.location.href;

        var pageURL = urlString.substring(urlString.indexOf("/s/") + 2);

        if (pageURL === '/') {
            if (homeMenu) homeMenu.getElement().classList.add("slds-is-active");
        } else if (pageURL.includes('global-search') || pageURL.includes('Empatia__c') || pageURL.includes('citizen-list') || pageURL.includes('empatia')) {
            if (citizenMenu) citizenMenu.getElement().classList.add("slds-is-active");
        } else if (pageURL.includes('argentina')) {
            if (dashboardMenu) dashboardMenu.getElement().classList.add("slds-is-active");
        } else if (pageURL.includes('territories') || pageURL.includes('territorio-administrativo')) {
            if (territoriesMenu) territoriesMenu.getElement().classList.add("slds-is-active");
        }
    }
})