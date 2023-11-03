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

export default class Section_educacion extends LightningElement {

    @api param_data_from_analytics;
    @api param_template;

    render() {
        return this.param_template ? TEMPLATES_BY_NAME[this.param_template] : default_template;
    }
    filterLabels = [];

    iconEduPrimaria = Resources + '/SALESFORCE/img/Territories/ne_primario.svg';
    iconEduSecundaria = Resources + '/SALESFORCE/img/Territories/ne_secundario.svg';
    iconEduTerciaria = Resources + '/SALESFORCE/img/Territories/ne_universitario.svg';
    iconEduUniversitaria = Resources + '/SALESFORCE/img/Territories/ne_universitario_completo.svg';

    get educationLevels() {
        let tempArray = [];

        let educationFromAnalitycs = this.param_data_from_analytics.Education.results;

        let primario = 0;
        let secundario = 0;
        let terciario = 0;
        let universitario = 0;

        educationFromAnalitycs.forEach(thisEducacion => {
            if (thisEducacion.Education.toUpperCase().includes('PRIMARIO')) {
                primario += thisEducacion.count;
            }
            if (thisEducacion.Education.toUpperCase().includes('SECUNDARIO')) {
                secundario += thisEducacion.count;
            }
            if (thisEducacion.Education.toUpperCase().includes('TERCIARIO')) {
                terciario += thisEducacion.count;
            }
            if (thisEducacion.Education.toUpperCase().includes('UNIVERSITARIO')) {
                universitario += thisEducacion.count;
            }
        })

        tempArray.push({ "name": "Primario completo", "image": this.iconEduPrimaria, "value": primario.toLocaleString('es-AR'), educationfilter: 'Primario' });
        tempArray.push({ "name": "Secundario completo", "image": this.iconEduSecundaria, "value": secundario.toLocaleString('es-AR'), educationfilter: 'Secundario' });
        tempArray.push({ "name": "Terciario completo / univ. incompleto", "image": this.iconEduTerciaria, "value": terciario.toLocaleString('es-AR'), educationfilter: 'Terciario' });
        tempArray.push({ "name": "Universitario completo", "image": this.iconEduUniversitaria, "value": universitario.toLocaleString('es-AR'), educationfilter: 'Universitario' });

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