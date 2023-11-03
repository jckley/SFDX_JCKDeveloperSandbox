import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';
import lblsmvm from '@salesforce/label/c.SMVM';

import default_template from './default_template.html';
import evolution_template from './evolution_template.html';

const TEMPLATES_BY_NAME = {
    'evolution_template': evolution_template
}

const FILTERS_BY_ITEMS_KEYS = {
    "BAJO": '["Bajo","Muy Bajo"]',
    "MEDIO": '["Medio"]',
    "ALTO": '["Alto","Muy Alto"]'
}

export default class Section_ingreso extends LightningElement {
    lblsmvm = lblsmvm;
    iconIngresoBajo = Resources + '/SALESFORCE/img/Territories/indicador_bajo.svg';
    iconIngresoMedio = Resources + '/SALESFORCE/img/Territories/indicador_medio.svg';
    iconIngresoAlto = Resources + '/SALESFORCE/img/Territories/indicador_alto.svg';


    @api param_data_from_analytics;
    @api param_template;

    render() {
        return this.param_template ? TEMPLATES_BY_NAME[this.param_template] : default_template;
    }


    selectedItemsKeys = [];


    get incomeRanges() {
        let tempArray = [];

        let ingresosFromAnalitycs = this.param_data_from_analytics?.Ingreso?.results ?? [];

        let ingresoBajo = 0;
        let ingresoMedio = 0;
        let ingresoAlto = 0;

        ingresosFromAnalitycs.forEach(thisIngreso => {
            if (thisIngreso.Ingreso === 'Alto' || thisIngreso.Ingreso === 'Muy Alto') {
                ingresoAlto += thisIngreso.count;
            }
            if (thisIngreso.Ingreso === 'Medio') {
                ingresoMedio += thisIngreso.count;
            }
            if (thisIngreso.Ingreso === 'Bajo' || thisIngreso.Ingreso === 'Muy Bajo') {
                ingresoBajo += thisIngreso.count;
            }
        })

        tempArray.push({ "name": "BAJO", "description": "menos de dos SMVM", "image": this.iconIngresoBajo, "value": ingresoBajo.toLocaleString('es-AR')});
        tempArray.push({ "name": "MEDIO", "description": "entre dos y seis SMVM", "image": this.iconIngresoMedio, "value": ingresoMedio.toLocaleString('es-AR')});
        tempArray.push({ "name": "ALTO", "description": "más de seis SMVM", "image": this.iconIngresoAlto, "value": ingresoAlto.toLocaleString('es-AR')});


        const tempArrayWithCss = tempArray.map(thisItem => {
            if (this.selectedItemsKeys.length === 0 || this.selectedItemsKeys.includes(thisItem.name)) {
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
        let tempFilters = {
            filterArray: [
                { filterField: 'Ingreso__c', filterComparisonOperator: 'in', filterComparisonValue: FILTERS_BY_ITEMS_KEYS[selectedKey] }
            ]
        }

        let label;

        if (selectedKey === "BAJO") label = 'Ingresos bajos';
        if (selectedKey === "MEDIO") label = 'Ingresos medios';
        if (selectedKey === "ALTO") label = 'Ingresos altos';

        const bindedFunction = function tempFunction() { this.togleLocalFilter(selectedKey) }.bind(this);

        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject: tempFilters, label: label, bindedFunction } });
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