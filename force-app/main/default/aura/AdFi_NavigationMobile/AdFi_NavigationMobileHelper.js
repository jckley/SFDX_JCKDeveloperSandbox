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
        if (id == '/logout'){
            var baseUrl = window.location;
            window.location.replace("/secur/logout.jsp?retUrl=https%3A%2F%2F" + baseUrl +"%2Flogin");
        } else if(id != '/'){
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
})