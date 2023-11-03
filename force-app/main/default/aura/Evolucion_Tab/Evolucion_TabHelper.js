({
    doTagSelected_CSSClasses : function(cmp) {
        console.log('helper')
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
        console.log('tabs, pageURL',pageURL);

        if (pageURL === '/') {
            console.log('entro /')
            console.log(Boolean(homeMenu))
            if (homeMenu) homeMenu.getElement().classList.add("slds-is-active");
        } else if (pageURL.includes('global-search') || pageURL.includes('contact') || pageURL.includes('citizen-list')) {
            console.log('entro searc')
            console.log(Boolean(citizenMenu))
            if (citizenMenu) citizenMenu.getElement().classList.add("slds-is-active");
        } else if (pageURL.includes('territories') || pageURL.includes('territorio-administrativo')) {
            console.log('entro terr')
            console.log(Boolean(territoriesMenu))
            if (territoriesMenu) territoriesMenu.getElement().classList.add("slds-is-active");
        } else if (pageURL.includes('dashboard')) {
            console.log('entro dash')
            console.log(Boolean(dashboardMenu))
            if (dashboardMenu) dashboardMenu.getElement().classList.add("slds-is-active");
        }
    }
})