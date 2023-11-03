import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/prosumerAudiencia';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, moviles: ';

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

export default class Prosumer_telefonos extends LightningElement {
    @api param_data_from_analytics;

    imgSource = Resources + '/celular.png';
    imgAlt = 'Teléfonos celulares';

    get value () {
        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {};
        const intValue = totalsFromAnalytics.Countable_TieneMobile ?? 0 ;
        return intValue.toLocaleString('es-AR');
    }

    name = 'Teléfonos celulares';

    get cssClasses() {
        if (this.isSelected) {
            return 'box selected';
        }
        return 'box';
    }

    isSelected = false;

    handelClick() {
        this.fireTogleEvent();
        this.togleLocalFilter();
    }

    fireTogleEvent() {
        const labelForEvent = 'Tiene telefono movil';
        const filterObjectForEvent = {
            filterArray: [{ filterField: 'MobilePhone', filterComparisonValue: 'not null', filterComparisonOperator: 'is' }]
        };
        const bindedFunction = function tempFunction () { this.togleLocalFilter() }.bind(this);
        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject: filterObjectForEvent, label: labelForEvent, bindedFunction } });
        this.dispatchEvent(filterClickEvent);
    }

    togleLocalFilter() {
        this.isSelected = !this.isSelected;
    }

    @api removeAllLocalFilters () {
        this.isSelected = false;
    }

}