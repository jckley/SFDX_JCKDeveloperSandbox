import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_IngresoTiles extends LightningElement {
    iconIngresoBajo = Resources + '/SALESFORCE/img/Territories/indicador_bajo.svg';
    iconIngresoMedio = Resources + '/SALESFORCE/img/Territories/indicador_medio.svg';
    iconIngresoAlto = Resources + '/SALESFORCE/img/Territories/indicador_alto.svg';

    //workframe params
    @api set results(value) {
        if(!value) return;
        this._results = value;

        let tempArray = [];

        let ingresosFromAnalitycs = value;

        let ingresoBajo = 0;
        let ingresoMedio = 0;
        let ingresoAlto = 0;

        ingresosFromAnalitycs.forEach(thisIngreso => {
            if (thisIngreso[this.labelColumnParam] === 'Alto' || thisIngreso[this.labelColumnParam] === 'Muy Alto') {
                ingresoAlto += thisIngreso[this.valueColumnParam];
            }
            if (thisIngreso[this.labelColumnParam] === 'Medio') {
                ingresoMedio += thisIngreso[this.valueColumnParam];
            }
            if (thisIngreso[this.labelColumnParam] === 'Bajo' || thisIngreso[this.labelColumnParam] === 'Muy Bajo') {
                ingresoBajo += thisIngreso[this.valueColumnParam];
            }
        })

        tempArray.push({ "name": "BAJO", "description": "menos de dos SMVM", "image": this.iconIngresoBajo, "value": ingresoBajo.toLocaleString(), 'filter':'Bajo'});
        tempArray.push({ "name": "MEDIO", "description": "entre dos y seis SMVM", "image": this.iconIngresoMedio, "value": ingresoMedio.toLocaleString(), 'filter':'Medio' });
        tempArray.push({ "name": "ALTO", "description": "más de seis SMVM", "image": this.iconIngresoAlto, "value": ingresoAlto.toLocaleString(), 'filter':'Alto' });

        this.tileList = tempArray;
    }
    get results() {
        return this._results;
    }
    @api metadata;
    @api setSelection;
    @api selectMode;

    @api getState;
    @api setState;
    @api selection;


    //custom params
    @api valueColumnParam;
    @api labelColumnParam;
    filterFieldParam = 'Ingreso__c';

    @track tileList = [];

    handleClickTile(event) {
        if(!this.filterFieldParam) return;

        let tempState = {...this.getState()};

        for (let thisConfigItem of tempState.state.datasets.TerritoryFullPage_DS){
            if(thisConfigItem.fields[0] === this.filterFieldParam){
                thisConfigItem.filter.operator = 'matches';
                thisConfigItem.filter.values = event.currentTarget.getAttribute('data-filter');
            }
        }
        this.setState(tempState);
    }
}