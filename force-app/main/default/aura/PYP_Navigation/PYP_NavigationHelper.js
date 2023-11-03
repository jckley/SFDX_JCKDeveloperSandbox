({
    getNavigationMenu : function(component) {
        var navigationMenu = null;
        var action = component.get("c.getNavigationMenuItems"); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                navigationMenu = response.getReturnValue();
                component.set('v.navigationMenu', navigationMenu);
            } 
        });
        $A.enqueueAction(action); 
    },
    
    navigateToItem : function(id) {
        if(id != '/'){
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": id
            });
            homeEvent.fire();
        } else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": (id)
            });
            urlEvent.fire();
        }
    },
    
    setActualPage : function (component) {
        var actualPage = window.location.href;
        if(actualPage.includes('contact')){
        	component.set('v.itemSelected', 'Contact');    
        }else if(actualPage.includes('territorio-administrativo')){
            component.set('v.itemSelected', 'Territorio_Administrativo__c');
        }else if(actualPage.includes('report')){
            component.set('v.itemSelected', 'Report');
        }else if(actualPage.includes('dashboard')){
            component.set('v.itemSelected', 'Dashboard');
        }else if(actualPage.includes('global-search')){
            component.set('v.itemSelected', '');
        }else{
            component.set('v.itemSelected', '/');
        }
    }
})