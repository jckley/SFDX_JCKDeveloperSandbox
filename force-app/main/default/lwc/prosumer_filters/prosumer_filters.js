import { LightningElement, api } from 'lwc';

import Resources from '@salesforce/resourceUrl/Communities';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, filters: ';

function customLog(...stringsToLog) {
    const strArray = [DEFAULT_LOG];
    const completeLog = strArray.concat(stringsToLog);

    //cuando los logs estan activos por default, logeo y retorno null  
    if (IS_LOG_ENABLED) {
        console.log(...completeLog);
        return { forceLog: () => null };
    }
    //cuando no, necesito una funcion para permitir loggear a manopla en algunos lugares    
    return { forceLog: () => console.log(...completeLog) };
}

export default class Prosumer_filters extends LightningElement {

    closeIcon = Resources + '/SALESFORCE/img/filterSection/closeIcon.svg#closeicon';
    filtroIcon = Resources + '/SALESFORCE/img/filterSection/filtroIcon.svg#filtroicon';

    filters = []
    @api
    param_data_from_analytics;

    get totalPersonas() {
        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {};

        let total = totalsFromAnalytics.Total ?? 0;
        return total.toLocaleString('es-AR');
    }

    get showCloseAll() {
        return this.filters.length > 0;
    }

    handleCloseItemClick(event) {
        const keyOfTheClickedElement = event.currentTarget.dataset.itemkey;
        console.log('keyOfTheClickedElement: ', keyOfTheClickedElement)
        const clickedElement = this.filters.find(thisFilter => thisFilter.filterString === keyOfTheClickedElement);
        const filterString = clickedElement.filterString;
        const clickedElementTerritoryLevel = clickedElement.territoryLevel;

        if (clickedElementTerritoryLevel) {
            //si clickeo en un territorio, tengo que ver si es el ultimo o no
            //const childTerritoryFilters = this.filters.filter(thisFilter)

            const lvlNumber = Number(clickedElementTerritoryLevel);

            const filterToRemove = this.filters.filter(thisFilter => {
                const esUnTerritorioDeNivelInferior = thisFilter.territoryLevel && Number(thisFilter.territoryLevel) > lvlNumber;
                const esElElementoClickeado = thisFilter.filterString === keyOfTheClickedElement;
                return esUnTerritorioDeNivelInferior || esElElementoClickeado
            });

            this.filters = this.filters.filter(thisFilter => !filterToRemove.includes(thisFilter));

            const filterObjects = filterToRemove.map(thisObject => JSON.parse(thisObject.filterString))

            const removeFiltersEvent = new CustomEvent('removeterritories', { detail: { oldFilters: filterObjects, newFilters: [], levelToSet: lvlNumber - 1 } });
            this.dispatchEvent(removeFiltersEvent);
            return;
        }

        console.log('thisFilteString: ', filterString)
        this.filters = this.filters.filter(thisFilter => thisFilter.filterString !== keyOfTheClickedElement);

        if (clickedElement.bindedFunction) {
            clickedElement.bindedFunction();
        }

        const removeFiltersEvent = new CustomEvent('removeone', { detail: { filterString: filterString } });
        this.dispatchEvent(removeFiltersEvent);
    }

    handleCloseAllClick() {
        this.dispatchEvent(new CustomEvent('removeall'));
        this.filters.forEach(thisFilterObj => {
            if (thisFilterObj.bindedFunction) { thisFilterObj.bindedFunction() }
        }
        )
        this.filters = [];

    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('clickejecutar'));
    }

    @api toggleFilter(filterToAdd) {
        if (this.filters.find(thisFilter => thisFilter.filterString === filterToAdd.filterString)) {
            this.filters = this.filters.filter(thisFilter => thisFilter.filterString !== filterToAdd.filterString);
            return;
        }
        const tempFilters = [...this.filters];
        tempFilters.push(filterToAdd);
        this.filters = tempFilters;
    }

    @api getFiltersLabels() {
        return this.filters.map(thisFilter => thisFilter.filterLabel);
    }

    @api removeFiltersFromList (arrayDefilterStringToRemove) {
        const stringsArray = arrayDefilterStringToRemove.map(thisObject => JSON.stringify(thisObject));
        this.filters = this.filters.filter(thisFilterItem=> !stringsArray.includes(thisFilterItem.filterString));
    }

}