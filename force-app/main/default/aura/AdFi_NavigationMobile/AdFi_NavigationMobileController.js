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
            component.find('mob-nav-menu-background').getElement().classList.add('slds-hide');
            component.find('mob-nav-menu').getElement().classList.add('slds-hide');
        }
    },
    
    closeNavigationMenu : function(component, event, helper) {
        component.find('mob-nav-menu-background').getElement().classList.add('slds-hide');
        component.find('mob-nav-menu').getElement().classList.add('slds-hide');
    },
    
    openNavigationMenu : function(component, event, helper) {
        component.find('mob-nav-menu-background').getElement().classList.remove('slds-hide');
        component.find('mob-nav-menu').getElement().classList.remove('slds-hide');
    }
})