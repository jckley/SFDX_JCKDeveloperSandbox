import { LightningElement, api } from 'lwc';

import Resources from '@salesforce/resourceUrl/prosumerAudiencia';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, ingreso: ';

function customLog(...stringsToLog) {
    const strArray = [DEFAULT_LOG];
    const completeLog = strArray.concat(stringsToLog);

    //cuando los logs estan activos por default, logeo y retorno null  
    if (IS_LOG_ENABLED) {
        console.log(...completeLog);
        return {forceLog:()=>null};
    }
    //cuando no, necesito una funcion para permitir loggear a manopla en algunos lugares    
    return {forceLog:()=>console.log(...completeLog)};
}

export default class Prosumer_ingreso extends LightningElement {

    nivingreso = Resources + '/ingresos.png';

    @api 
    set param_data_from_analytics (value) {
        this._param_data_from_analytics = value;
    }

    get param_data_from_analytics () {
        return this._param_data_from_analytics;
    }

    _param_data_from_analytics;

    selectedItemsKeys = [];

    get incomeRanges() {
        let tempArray = [];

        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {};

        //si mal no recuerdo, en algunos casos, cuando la query suma 0 para una categoria, no devuelve la categoria directamente
        let ingresosToShow = {};

        ingresosToShow['Muy Bajo'] = totalsFromAnalytics['RI_MuyBajo'] ?? 0;
        ingresosToShow['Bajo'] = totalsFromAnalytics['RI_Bajo'] ?? 0;
        ingresosToShow['Medio'] = totalsFromAnalytics['RI_Medio'] ?? 0;
        ingresosToShow['Alto'] = totalsFromAnalytics['RI_Alto'] ?? 0;
        ingresosToShow['Muy Alto'] = totalsFromAnalytics['RI_MuyAlto'] ?? 0;

        tempArray.push({ "name": "MUY BAJO", "description": "< 1 SMVM", "value": ingresosToShow['Muy Bajo'].toLocaleString('es-AR'), id:'Muy Bajo'});
        tempArray.push({ "name": "BAJO", "description": "1 <> 2 SMVM", "value": ingresosToShow['Bajo'].toLocaleString('es-AR'), id:'Bajo'});
        tempArray.push({ "name": "MEDIO", "description": "2 <> 6 SMVM", "value": ingresosToShow['Medio'].toLocaleString('es-AR'), id:'Medio'});
        tempArray.push({ "name": "ALTO", "description": "6 <> 18 SMVM", "value": ingresosToShow['Alto'].toLocaleString('es-AR'), id:'Alto'});
        tempArray.push({ "name": "MUY ALTO", "description": "> 18 SMVM", "value": ingresosToShow['Muy Alto'].toLocaleString('es-AR'), id:'Muy Alto'});


        const tempArrayWithCss = tempArray.map(thisItem => {
            if (this.selectedItemsKeys.length === 0 || this.selectedItemsKeys.includes(thisItem.id)) {
                return {
                    ...thisItem,
                    cssClasses: 'item'
                }
            }
            return {
                ...thisItem,
                cssClasses: 'item notSelected'
            }
        });

        return tempArrayWithCss;
    }

    handelClick_IngresosItem(event) {
        let selectedKey = event.currentTarget.dataset.itemkey;

        this.fireTogleEvent(selectedKey);
        this.togleLocalFilter(selectedKey);
    }

    fireTogleEvent(selectedKey) {

        //{filterArray,isBaseFilter,filterLogicalOperator}

        const FILTERS_BY_ITEMS_KEYS = {
            "Muy Bajo": '["Muy Bajo"]',
            "Bajo": '["Bajo"]',
            "Medio": '["Medio"]',
            "Alto": '["Alto"]',
            "Muy Alto": '["Muy Alto"]'
        }

        let tempFilters = {
            filterArray: [
                { filterField: 'Ingreso__c', filterComparisonOperator: 'in', filterComparisonValue: FILTERS_BY_ITEMS_KEYS[selectedKey] }
            ]
        }

        let label;

        if (selectedKey === 'Muy Bajo') label = 'Ingresos muy bajos';
        if (selectedKey === 'Bajo') label = 'Ingresos bajos';
        if (selectedKey === 'Medio') label = 'Ingresos medios';
        if (selectedKey === 'Alto') label = 'Ingresos altos';
        if (selectedKey === 'Muy Alto') label = 'Ingresos muy altos';

        console.log('label', label );
        const bindedFunction = function tempFunction() { this.togleLocalFilter(selectedKey) }.bind(this);

        const filterClickEvent  = new CustomEvent('filterclick', { detail: { filterObject: tempFilters, label: label, bindedFunction } });
        this.dispatchEvent(filterClickEvent);
    }

    togleLocalFilter(selectedKey) {
        if(!this.selectedItemsKeys.includes(selectedKey)){
            this.selectedItemsKeys = [...this.selectedItemsKeys, selectedKey]
            return;
        }

        this.selectedItemsKeys = this.selectedItemsKeys.filter(thisItem => thisItem !== selectedKey);
    }


    @api removeAllLocalFilters () {
        this.selectedItemsKeys = [];
    }
}