({
	doInit : function(component, event, helper) {
        helper.setActualPage(component);
		helper.getNavigationMenu(component);
	},
    
    navigateToItem : function(component, event, helper) {
        var id = event.target.dataset.target;
		console.log('menu de navegacion navega');
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