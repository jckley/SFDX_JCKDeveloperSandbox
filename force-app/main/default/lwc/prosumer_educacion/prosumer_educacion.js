import { LightningElement, api } from 'lwc';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, educacion: ';

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

export default class Prosumer_educacion extends LightningElement {
    @api param_data_from_analytics;

    filterLabels = [];

    get educationLevels() {
        let tempArray = [];

        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {};

        let analfabeto = totalsFromAnalytics['ED_Analfabeto'] ?? 0;
        let primario = totalsFromAnalytics['ED_Primario'] ?? 0;
        let secundario = totalsFromAnalytics['ED_Secundario'] ?? 0;
        let terciario = totalsFromAnalytics['ED_Terciario'] ?? 0;
        let universitario = totalsFromAnalytics['ED_UniversitarioCompleto'] ?? 0;

        tempArray.push({ "name": "ANALFABETO", "value": analfabeto.toLocaleString('es-AR'), educationfilter: 'Analfabeto' });
        tempArray.push({ "name": "PRIMARIO", "value": primario.toLocaleString('es-AR'), educationfilter: 'Primario' });
        tempArray.push({ "name": "SECUNDARIO", "value": secundario.toLocaleString('es-AR'), educationfilter: 'Secundario' });
        tempArray.push({ "name": "TERCIARIO", "value": terciario.toLocaleString('es-AR'), educationfilter: 'Terciario' });
        tempArray.push({ "name": "UNIVERSITARIO", "value": universitario.toLocaleString('es-AR'), educationfilter: 'Universitario' });

        const tempArrayWithCss = tempArray.map( thisItem => {
            if(this.filterLabels.length === 0 || this.filterLabels.includes(thisItem.educationfilter)){
                return {
                    ...thisItem,
                    cssClases: 'item'
                }
            }
            return {
                ...thisItem,
                cssClases: 'item notSelected'
            }
        });

        return tempArrayWithCss;
    }

    handelClick_Education(event) {
        let clickedLabel = event.currentTarget.dataset.educationfilter;
        this.fireTogleEvent (clickedLabel);
        this.togleLocalFilter (clickedLabel);
    }

    fireTogleEvent(clickedLabel) {
        let filterObject = {
            filterArray: [
                { filterField: 'Education_Level__c', filterComparisonOperator: 'matches', filterComparisonValue: clickedLabel }
            ]
        }

        const bindedFunction = function tempFunction () { this.togleLocalFilter(clickedLabel) }.bind(this);

        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject, label:clickedLabel, bindedFunction } });
        this.dispatchEvent(filterClickEvent);
    }

    togleLocalFilter(clickedLabel) {
        if(!this.filterLabels.includes(clickedLabel)){
            this.filterLabels = [...this.filterLabels, clickedLabel]
            return;
        }

        this.filterLabels = this.filterLabels.filter(thisItem => thisItem !== clickedLabel);
    }

    @api removeAllLocalFilters () {
        this.filterLabels = [];
    }

}