import { LightningElement, api } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/prosumerAudiencia';

export default class Prosumer_audienciaGeneracional_cards extends LightningElement {

    sub16 = RESOURCES + "/1.png";
    centennials  = RESOURCES + "/2.png";
    millenials = RESOURCES + "/3.png";
    generacionx = RESOURCES + "/4.png";
    babyboomers = RESOURCES + "/5.png";
    gensilenciosa = RESOURCES + "/6.png";


    @api
    set param_data_from_analytics(value) {
        this._param_data_from_analytics = value;
    }

    get param_data_from_analytics() {
        return this._param_data_from_analytics;
    }

    _param_data_from_analytics;

    get agesData_forCards() {


        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {};

        let dataObjectWithDefaultValues = {
            'SUB 16': totalsFromAnalytics['AG_SUB_16'] ?? 0,
            'CENTENNIALS': totalsFromAnalytics['AG_CENTENNIALS'] ?? 0,
            'MILENNIALS': totalsFromAnalytics['AG_MILENNIALS'] ?? 0,
            'GENERACION X': totalsFromAnalytics['AG_GENERACION_X'] ?? 0,
            'BABY BOOMERS': totalsFromAnalytics['AG_BABY_BOOMERS'] ?? 0,
            'GENERACION SILENCIOSA': totalsFromAnalytics['AG_GENERACION_SILENCIOSA'] ?? 0,
        };


        let tempArray = [];

        tempArray.push({ "name": 'SUB 16', "description": "Mayor a 2005", "image": this.sub16, "value": dataObjectWithDefaultValues['SUB 16'].toLocaleString('es-AR'), filter: 'SUB 16' });
        tempArray.push({ "name": 'Centennials', "description": "1995 - 2003", "image": this.centennials, "value": dataObjectWithDefaultValues['CENTENNIALS'].toLocaleString('es-AR'), filter: 'CENTENNIALS' });
        tempArray.push({ "name": 'Millenials', "description": "1980 - 1994", "image": this.millenials, "value": dataObjectWithDefaultValues['MILENNIALS'].toLocaleString('es-AR'), filter: 'MILENNIALS' });
        tempArray.push({ "name": 'Generación X', "description": "1965 - 1979", "image": this.generacionx, "value": dataObjectWithDefaultValues['GENERACION X'].toLocaleString('es-AR'), filter: 'GENERACION X' });
        tempArray.push({ "name": 'Baby Boomers', "description": "1944 - 1964", "image": this.babyboomers, "value": dataObjectWithDefaultValues['BABY BOOMERS'].toLocaleString('es-AR'), filter: 'BABY BOOMERS' });
        tempArray.push({ "name": 'Gen. Silenciosa', "description": "Menos a 1944", "image": this.gensilenciosa, "value": dataObjectWithDefaultValues['GENERACION SILENCIOSA'].toLocaleString('es-AR'), filter: 'GENERACION SILENCIOSA' });


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


    selectedLabels = [];

    handelClick_cardAudienciaGeneracional(event) {
        let label = event.currentTarget.dataset.filtervalue;
        this.fireTogleEvent (label);
        this.togleLocalFilter (label);
    }

    fireTogleEvent(label){

        let tempFilter = [];

        tempFilter.push({ filterField: 'Audiencia_Generaciones__c', filterComparisonValue: label, filterComparisonOperator: '==' });

        const bindedFunction = function tempFunction () { this.togleLocalFilter(label) }.bind(this);

         // Set the values directly in the component
            let labelForFilter;
            switch (label) {
                case 'SUB 16':
                    labelForFilter = 'SUB 16';
                    break;
                case 'CENTENNIALS':
                    labelForFilter = 'Centennials';
                    break;
                case 'MILENNIALS':
                    labelForFilter = 'Millenials';
                    break;
                case 'GENERACION X':
                    labelForFilter = 'Generación X';
                    break;
                case 'BABY BOOMERS':
                    labelForFilter = 'Baby Boomers';
                    break;
                case 'GENERACION SILENCIOSA':
                    labelForFilter = 'Gen. Silenciosa';
                    break;
                default:
                    break;
            }


        
        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject: {filterArray:tempFilter}, label: labelForFilter, bindedFunction } });
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