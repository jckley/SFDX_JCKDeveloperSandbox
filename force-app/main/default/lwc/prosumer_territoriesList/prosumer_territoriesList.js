import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/prosumerAudiencia';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, territoriesList: ';

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

export default class Prosumer_territoriesList extends LightningElement {

    territorioicon = Resources + '/distterritorial.png';
    iconMarker = Resources + '/pointmap.png';


    //los getters and setters tienen que venir SIEMPRE DE APARES!
    //si pones un set, y no el set, el componente rompe y no te dice que pasa...
    _param_data_from_analytics;

    @api
    set param_data_from_analytics(value) {
        this._param_data_from_analytics = value;
    }
    get param_data_from_analytics() {
        return this._param_data_from_analytics;
    }

    filtersAplied = [];

    lastgeographicDistribution;
    selectedLvl;

    get geographicDistribution() {
        customLog('geographicDistribution');
        let tempArray = [];

        let childTerritoriesFromAnalitycs = this.param_data_from_analytics.ChildTerritories.results;

        customLog('geographicDistribution, analytics data: ', JSON.stringify(childTerritoriesFromAnalitycs));

        let territoryLevel;

        if (childTerritoriesFromAnalitycs.length !== 0) {
            const someTerritory = childTerritoriesFromAnalitycs[0];
            customLog('territoryLevel: ' , someTerritory);
            Object.keys(someTerritory).forEach(thisKeyOfTheObject => {
                if (thisKeyOfTheObject.includes('Level')) {
                    territoryLevel = thisKeyOfTheObject.substring(5,6);
                }
            })
        }

        customLog('territoryLevel: ' , territoryLevel);
        this.selectedLvl = territoryLevel;

        for (let thisTerritory of childTerritoriesFromAnalitycs) {
            tempArray.push(
                {
                    "id": thisTerritory.Id,
                    "filterValue": thisTerritory.Id,
                    "name": thisTerritory.Name,
                    "value": thisTerritory.count,
                    "territoryLevel":territoryLevel
                }
            );
        }


        let sortedArray = tempArray.sort((a, b) => { return b.value - a.value });

        //un poco de mutacion por aqui, un poco de mutacion por alla
        sortedArray.forEach(thisElement => {
            thisElement.value = thisElement.value.toLocaleString('es-AR')
        })
        return sortedArray;
    }

    handleItemClick(event) {
        const territoryId = event.currentTarget.dataset.filtervalue;
        const filterLabel = event.currentTarget.dataset.filterlabel;
        const territoryLevel = event.currentTarget.dataset.territorylevel;
        this.addFilterAndFireEvent(territoryId, filterLabel, territoryLevel);
    }

    addFilterAndFireEvent(territoryId, filterLabel, territoryLevel) {

        //en algun punto va a hacer falta armar algo para obtener una primer lista de territorios como base.
        //va a depender de como quieran que se comporte la seccion de seleccion de territorios
        //se podria poner directamente en el Manager? O armar otra query en el service... No se, o directamente en el componente de la seccion
        //pero tendria que recibir el admin lvl

        const filterObjectForEvent = {
            filterArray: [{ filterField: 'fx_TerritoryTree', filterComparisonValue: `"%${territoryId}%"`, filterComparisonOperator: 'like' }]
        };

        const labelForEvent = filterLabel;

        
        const bindedFunction = function tempFunction() {}

        this.filtersAplied.push({ filterString: JSON.stringify(filterObjectForEvent), label: labelForEvent, territoryLevel});

        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject: filterObjectForEvent, label: labelForEvent, bindedFunction, territoryLevel } });
        this.dispatchEvent(filterClickEvent);
    }

    handleRemoveFilter(event) {
        const filterString = event.currentTarget.dataset.filterstring;
        const filterLevelString = event.currentTarget.dataset.filterlevel;
        //ojo el orden! No puedo primero remover los filtros del array y despues tratar de econtrarlos...
        this.sendRemoveFiltersEvent(filterString, Number(filterLevelString));
        this.removeFilterTree(filterString, Number(filterLevelString));
    }

    removeFilterTree(filterString, filterLevel) {
        this.filtersAplied = this.filtersAplied.filter(thisFilter => {
            const isClickedFilter = thisFilter.filterString === filterString;
            const esNivelHijo = thisFilter.territoryLevel > filterLevel
            return !(isClickedFilter || esNivelHijo)
        });
    }

    sendRemoveFiltersEvent (filterString, filterLevel) {
        const filtersToRemove = this.filtersAplied.filter(thisFilter => {
            const isClickedFilter = thisFilter.filterString === filterString;
            const esNivelHijo = thisFilter.territoryLevel > filterLevel
            return isClickedFilter || esNivelHijo
        });

        const filterObjects = filtersToRemove.map(thisObject => JSON.parse(thisObject.filterString))

        const removeFiltersEvent = new CustomEvent('removeterritories', { detail: { oldFilters: filterObjects, newFilters: [], levelToSet: filterLevel - 1 } });
        this.dispatchEvent(removeFiltersEvent);
    }

    @api removeAllLocalFilters() {
        this.filtersAplied = [];
    }

    @api removeFiltersFromList (arrayDefilterStringToRemove) {
        const stringsArray = arrayDefilterStringToRemove.map(thisObject => JSON.stringify(thisObject));
        const newFilters = this.filtersAplied.filter(thisFilterItem=> !stringsArray.includes(thisFilterItem.filterString));
        this.filtersAplied = newFilters;
    }


}