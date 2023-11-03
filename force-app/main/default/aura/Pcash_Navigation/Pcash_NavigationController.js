({
	doInit : function(component, event, helper) {
        var actualPage = window.location.href;
        if(actualPage.includes('contact')){
        	component.set('v.itemSelected', 'Contact');    
        } else if(actualPage.includes('territorio-administrativo')){
            component.set('v.itemSelected', 'Territorio_Administrativo__c');
        }
		helper.getNavigationMenu(component);
	},
    
    navigateToItem : function(component, event, helper) {
        var id = event.target.dataset.target;

        if (id) {
            helper.navigateToItem(id);
            component.set('v.itemSelected', event.target.dataset.target);
        }
    },
    
    changeSelection : function(component, event, helper) {
        var type = event.getParams('searchType').searchType;
        if(type == 'Ciudadano') {
            component.set('v.itemSelected', 'Contact'); 
        }else if(type == 'Territorio'){
            component.set('v.itemSelected', 'Territorio_Administrativo__c'); 
        }else {
            component.set('v.itemSelected', '');
        }
    }
})