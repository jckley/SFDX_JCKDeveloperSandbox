import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';
import default_template from './default_template.html';
import evolution_template from './evolution_template.html';

const TEMPLATES_BY_NAME = {
    'evolution_template': evolution_template
}

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}


//esto esta maso, hay que verificar que siempre esten sincronizados con los valores que usa y que espera la query.
//pero bueno, a su vez, el requerimiento es que las actividades se tienen que mostrar aunque la query de 0 (en cuyo caso no la devuelve)
const ACTIVIDADES_ECONOMICAS_DEFAULT = {
    'Arte y recreación': 0,
    'Comercio': 0,
    'Comunicación e información': 0,
    'Construcción': 0,
    'Gestión de desechos': 0,
    'Educación': 0,
    'Extractivismo': 0,
    'Finanzas y aseguradoras': 0,
    'Gas y electricidad': 0,
    'Hotelería y gastronomía': 0,
    'Industrias manufactureras': 0,
    'Inmobiliarias': 0,
    'Justicia': 0,
    'Reparaciones y oficios': 0,
    'Empleo público': 0,
    'Reparaciones y suministro de servicios básicos': 0,
    'Rural': 0,
    'Salud': 0,
    'Fuerzas de seguridad': 0,
    'Servicios profesionales': 0,
    'Tecnología': 0,
    'Transporte': 0,
}

export default class Section_actividadesEconomicas extends LightningElement {

    iconEmpleado = Resources + '/SALESFORCE/img/Territories/ae_empleado.svg';

    @api param_data_from_analytics;
    @api param_template;

    render() {
        return this.param_template ? TEMPLATES_BY_NAME[this.param_template] : default_template;
    }

    selectedLabels = [];

    get actividadesEconomicas() {
        let data = {
            ...ACTIVIDADES_ECONOMICAS_DEFAULT
        };

        let queryData = this.param_data_from_analytics.ActEco?.results[0];

        if (queryData) {
            data = {
                ...queryData
            };
        }

        let tempArray = [];

        Object.entries(data).forEach(([key, value]) => {
            tempArray.push({
                "image": this.iconEmpleado,
                "name": key,
                "value": value,
                "actividadfilter": key,
            })

        });


        let sortedArray = tempArray.sort((a, b) => { return b.value - a.value });

        sortedArray.forEach(thisElement => {
            thisElement.value = thisElement.value.toLocaleString('es-AR')
        })

        const tempArrayWithCss = sortedArray.map( thisItem => {
            if(this.selectedLabels.length === 0 || this.selectedLabels.includes(thisItem.actividadfilter)){
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

    handelClick_Actividades(event) {
        let label = event.currentTarget.dataset.actividadfilter;
        this.fireTogleEvent (label);
        this.togleLocalFilter (label);
    }

    fireTogleEvent(label){
        //{filterArray,isBaseFilter,filterLogicalOperator}
        let filterObject = {
            filterArray: [
                { filterField: 'actividades_economicas__c', filterComparisonOperator: 'matches', filterComparisonValue: label }
            ]
        }

        //funcion a modo de callback que el otro componente usa para remover filtros de forma directa

        //tempFunction hace de wrapper a la funcion local de togleLocalFilter y "guardando",
            //el valor de "label" de cuando el codigo paso por aca, tonces el callback,
            // cuando se ejecuta, utiliza el valor correcto

        //la parte de .bind()
            // la puse para asegurarme que togleLocalFilter siga teniendo acceso a este componente

        //finalmente el otro componente hace un bindedFunction(), cuando quiera sacar un label del array de filtros
        const bindedFunction = function tempFunction () { this.togleLocalFilter(label) }.bind(this);

        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject, label, bindedFunction } });
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