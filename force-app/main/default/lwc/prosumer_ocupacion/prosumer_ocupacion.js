import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/prosumerAudiencia';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, ocupacion: ';

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

export default class Prosumer_ocupacion extends LightningElement {
    @api param_data_from_analytics;

    iconOcuAsalariado = Resources + '/asalariado.png';
    iconOcuCuentapropista = Resources + '/cuentapropistas.png';
    iconOcuJubilado = Resources + '/jubilados.png';
    iconOcuSinIngreso = Resources + '/sindecla.png';


    selectedLabels = [];

    get occupationTypes() {
        let data = this.param_data_from_analytics.Counting_All?.results[0] ?? { 'Asalariado': 0, 'Cuenta propia': 0, 'Jubilados y pensionados': 0, 'Sin ocupacion declarada': 0 };

        let tempArray = [];

        tempArray.push({ "name": 'ASALARIADOS', "image": this.iconOcuAsalariado, "value": data['Asalariado'].toLocaleString('es-AR'), filter: 'Asalariado' });
        tempArray.push({ "name": 'CUENTAPROPISTAS', "image": this.iconOcuCuentapropista, "value": data['Cuenta propia'].toLocaleString('es-AR'), filter: 'Cuentapropista' });
        tempArray.push({ "name": 'JUBILADOS Y PENSIÓN', "image": this.iconOcuJubilado, "value": data['Jubilados y pensionados'].toLocaleString('es-AR'), filter: 'Jubilados y pensionados' });
        tempArray.push({ "name": 'SIN INGRESOS DECLA.', "image": this.iconOcuSinIngreso, "value": data['Sin ocupacion declarada'].toLocaleString('es-AR'), filter: 'Ocupacion sin declarar' });


        const tempArrayWithCss = tempArray.map( thisItem => {
            if(this.selectedLabels.length === 0 || this.selectedLabels.includes(thisItem.filter)){
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

    handelClick_Ocupation(event) {
        //los filtros tambien podrian ser sobre las nuevas columnas calculadas. Despues habra que ver como queda mas prolijo. 
        let label = event.currentTarget.dataset.ocupationfilter;
        this.fireTogleEvent (label);
        this.togleLocalFilter (label);
    }

    fireTogleEvent(label){

        let labelForEvent;
        let filterObjectForEvent;

        if (label === 'Ocupacion sin declarar') {
            filterObjectForEvent = {
                filterArray: [{ filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'null', filterComparisonOperator: 'is' }]
            };

            labelForEvent = 'Ocupacion sin declarar';
        }

        if (label === 'Asalariado') {
            filterObjectForEvent = {
                filterArray: [{ filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Asalariado', filterComparisonOperator: 'matches' }]
            };

            labelForEvent = 'Asalariado';
        }
        if (label === 'Jubilados y pensionados') {
            filterObjectForEvent = {
                filterArray: [{ filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Jubilados y pensionados', filterComparisonOperator: 'matches' }]
            };

            labelForEvent = 'Jubilados y pensionados';
        }
        if (label === 'Cuentapropista') {
            filterObjectForEvent = {
                filterArray: [
                    { filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Cooperativas y precaria', filterComparisonOperator: 'matches' },
                    { filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Cuenta propia', filterComparisonOperator: 'matches' }
                ],
                filterLogicalOperator: '||'
            };

            labelForEvent = 'Cuentapropista';
        }

        const bindedFunction = function tempFunction () { this.togleLocalFilter(label) }.bind(this);

        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject: filterObjectForEvent, label: labelForEvent, bindedFunction } });
        this.dispatchEvent(filterClickEvent);
    }

    togleLocalFilter(clickedLabel) {
        if(!this.selectedLabels.includes(clickedLabel)){
            this.selectedLabels = [...this.selectedLabels, clickedLabel]
            return;
        }

        this.selectedLabels = this.selectedLabels.filter(thisItem => thisItem !== clickedLabel);
    }

    @api removeAllLocalFilters () {
        this.selectedLabels = [];
    }
    

}