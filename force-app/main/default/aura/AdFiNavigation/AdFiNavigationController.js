({
	doInit : function(component, event, helper) {
        var actualPage = window.location.href;
        if(actualPage.includes('contact')){
        	component.set('v.itemSelected', 'Contact');    
        }else if(actualPage.includes('territorio-administrativo')){
            component.set('v.itemSelected', 'Territorio_Administrativo__c');
        }else if(actualPage.includes('report')){
            component.set('v.itemSelected', 'Report');
        }else if(actualPage.includes('dashboard')){
            component.set('v.itemSelected', 'Dashboard');
        }else{
            component.set('v.itemSelected', '/');
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
        console.log('hola: ' + type);
        if(type == 'Ciudadano') {
            component.set('v.itemSelected', 'Contact'); 
        }else if(type == 'Territorio'){
            component.set('v.itemSelected', 'Territorio_Administrativo__c'); 
        }else {
            component.set('v.itemSelected', '');
        }
    }
})