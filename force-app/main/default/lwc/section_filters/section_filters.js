import { LightningElement, api } from 'lwc';

import Resources from '@salesforce/resourceUrl/Communities';

export default class Section_filters extends LightningElement {

    closeIcon = Resources+'/SALESFORCE/img/filterSection/closeIcon.svg#closeicon';
    filtroIcon = Resources+'/SALESFORCE/img/filterSection/filtroIcon.svg#filtroicon';
    
    filters = []

    get renderComponent () {
        return this.filters.length !== 0;
    }

    handleCloseItemClick(event) {
        const keyOfTheClickedElement = event.currentTarget.dataset.itemkey;
        console.log('keyOfTheClickedElement: ' , keyOfTheClickedElement)
        const clickedElement = this.filters.find(thisFilter => thisFilter.filterLabel === keyOfTheClickedElement);
        const filterString = clickedElement.filterString;
        console.log('thisFilteString: ' , filterString)
        this.filters = this.filters.filter(thisFilter => thisFilter.filterLabel !== keyOfTheClickedElement);

        if (clickedElement.bindedFunction) {
            clickedElement.bindedFunction();
        }
    
        const removeFiltersEvent = new CustomEvent('removeone', { detail: {filterString:filterString} });
        this.dispatchEvent(removeFiltersEvent);
    }

    handleCloseAllClick() {
        this.filters = [];
        this.dispatchEvent(new CustomEvent('removeall'));
    }

    @api toggleFilter (filterToAdd) {
        if(this.filters.find(thisFilter => thisFilter.filterString === filterToAdd.filterString)){
            this.filters = this.filters.filter(thisFilter => thisFilter.filterString !== filterToAdd.filterString);
            return;
        }
        const tempFilters = [...this.filters];
        tempFilters.push(filterToAdd);
        this.filters = tempFilters;
    }

}