({
    handleInit: function (cmp, event, helper) {
        var action = cmp.get("c.retrieveLoggedUserPermissions");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapOfPermissions = response.getReturnValue().permissionsMap;
                if (mapOfPermissions.Tab_Dashboard) {
                    cmp.set('v.access_dashboar', true);
                }
                if (mapOfPermissions.Tab_Territories) {
                    cmp.set('v.access_territory', true);
                }
                cmp.set('v.access_loaded', true);
            }
            //por ahora lo saco
            cmp.set('v.access_dashboar', true);
            console.log('handleInit callback')
        });
        $A.enqueueAction(action);
    },
    handleRouteChange: function (cmp, event, helper) {
        console.log('handleRouteChange')
        helper.doTagSelected_CSSClasses(cmp)
    },
    handleRender: function (cmp, event, helper) {
        console.log('handleRender')
        helper.doTagSelected_CSSClasses(cmp);
    },
    home: function (component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL + "/s/");
    },
    activistas: function (component, event, helper) {
        console.log('handler1')
        var navService = component.find("navService");
        console.log('handler2')
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Empatia__c',
                actionName: 'list'
            }
        };
        console.log('handler3')
        navService.navigate(pageReference);
        console.log('handler4')
    },
    territories: function (component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.replace(baseURL + "/s/territories");
    },
    // changeProfile : function(component, event, helper) {
    //     var urlString = window.location.href;
    //     var baseURL = urlString.substring(0, urlString.indexOf("/s"));
    //     window.location.replace(baseURL +"/s/cambiar-perfil-usuario");
    // },
    dashboard: function (component, event, helper) {
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: 'a2L6A000000EILzUAO',
                actionName: 'view',
            }
        };
        console.log('handler3')
        navService.navigate(pageReference);
        console.log('handler4')
    },
})