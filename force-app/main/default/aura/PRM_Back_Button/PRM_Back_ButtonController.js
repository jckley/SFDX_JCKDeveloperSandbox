({
    doInit : function(cmp, event,helper) { 
        //Get the event using event name. 
        var appEvent = $A.get("e.c:PRMCommunityEvent"); 
        //Set event attribute value
        appEvent.setParams({"message" : "Back_Button"}); 
        appEvent.fire(); 
    },
    back : function(){
        window.history.back();
    }
})