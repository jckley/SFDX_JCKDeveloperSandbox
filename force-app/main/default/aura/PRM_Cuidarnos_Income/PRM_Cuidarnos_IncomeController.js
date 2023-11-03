({
	goToCompany : function(objComponent, objEvent, objHelper) {
        var strData = null;
        var strUrl = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.search !== undefined && objEvent.currentTarget.dataset.search !== null && objEvent.currentTarget.dataset.search.length > 0) {
            strData = objEvent.currentTarget.dataset.search;

            strUrl = '/global-search/' + encodeURIComponent(strData)

            objEvent = $A.get("e.force:navigateToURL");
            objEvent.setParams({
              "url": strUrl
            });

            objEvent.fire();
        }
    }
})