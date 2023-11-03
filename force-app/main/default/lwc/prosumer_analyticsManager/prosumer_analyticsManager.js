import { LightningElement, api, wire } from 'lwc';
import { getDataset } from 'lightning/analyticsWaveApi';

//el componente tiene la logica para manejar colecciones de analyticsServices.
// Puntualmente las que hacen las querys de para territoryDetail 

const QUERYS_LIST = [
    { actKey: 'ChildTerritories', queryDefinition: 'BY_CHILD_TERRITORY' },
    { actKey: 'Counting_All' ,queryDefinition: 'BY_ALL'},
    //replaced in component, pending other places:
    //{ actKey: 'Email' ,queryDefinition: 'EMAIL'},
    //{ actKey: 'HomePhones' ,queryDefinition: 'HOME_PHONE'},
    //{ actKey: 'Mobile' ,queryDefinition: 'MOBILE'},
    //{ actKey: 'Address' ,queryDefinition: 'ADDRESS'},
    //{ actKey: 'Total' ,queryDefinition: 'TOTAL'},
    //replaced in counting all:
    //{ actKey: 'Ages', queryDefinition: 'BY_AGES' },
    //{ actKey: 'Gender', queryDefinition: 'BY_GENDER' },
    //{ actKey: 'Ingreso', queryDefinition: 'BY_INGRESO' },
    //{ actKey: 'Education', queryDefinition: 'BY_EDUCATION' },
    //{ actKey: 'ActEco' ,queryDefinition: 'BY_ACTIVIDAD_ECONOMICA'},
    //{ actKey: 'TipoOcu' ,queryDefinition: 'BY_OCUPACION'},
]

const IS_LOG_ENABLED = true;
const DEFAULT_LOG = 'Prosumer, analyticsManager: ';

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

export default class Prosumer_analyticsManager extends LightningElement {

        //en algun punto va a hacer falta armar algo para obtener una primer lista de territorios como base.
        //va a depender de como quieran que se comporte la seccion de seleccion de territorios
        //se podria poner directamente en el Manager? O armar otra query en el service... No se, o directamente en el componente de la seccion
        //pero tendria que recibir el admin lvl

    @api param_child_level_name;
    @api param_child_level_id;

    @api param_dataset_name;
    //default: 'TerritoryFullPage_DS'

    @api param_base_string_filter;

    param_data_set;
    param_data_set_version;

    querysToDo = [];

    querysResults = {};

    _servicesComponets
    get servicesComponets() {
        if (!this._servicesComponets) {
            this._servicesComponets = this.template.querySelectorAll('c-prosumer_analytics_service')
        }
        return this._servicesComponets;
    }

    connectedCallback() {
        customLog('iniciando analitycs manager');

        customLog('base string filter: ', this.param_base_string_filter);

        QUERYS_LIST.forEach(thisQuery => {
            if (thisQuery.queryDefinition === 'BY_CHILD_TERRITORY' && !this.param_child_level_name) return
            this.querysResults[thisQuery.actKey] = { results: undefined, error: undefined };
        })

        let tempOthers = QUERYS_LIST.map(thisQuery => {
            return {
                key: thisQuery.actKey,
                queryDefinition: thisQuery.queryDefinition
            }
        });

        customLog('luego del map, se arma objeto que inicia la creacion de los services');

        let tempsQuerys = [];

        tempsQuerys.push(...tempOthers);

        customLog('temp querys:', tempsQuerys);

        this.querysToDo = tempsQuerys;
    }

    @api addTemporaryFilter(filter) {
        customLog('Manager addTemporaryFilter');

        for (let value in this.querysResults) {
            if (Object.prototype.hasOwnProperty.call(this.querysResults, value)) {
                this.querysResults[value] = { results: undefined, error: undefined }
            }
        }

        for (let thisService of this.servicesComponets) {
            thisService.addTemporaryFilter(filter);
        }
    }

    @api toggleTemporaryFilter(filter) {
        customLog('Manager toggleTemporaryFilter');


        for (let value in this.querysResults) {
            //llama la funcion hasOwnProperty en el objeto queryResults para chekear si tiene la propiedad value
            if (Object.prototype.hasOwnProperty.call(this.querysResults, value)) {
                this.querysResults[value] = { results: undefined, error: undefined }
            }
        }

        for (let thisService of this.servicesComponets) {
            thisService.toggleTemporaryFilter(filter);
        }
    }

    @api replaceFilterArray(oldFiltersArray, newFiltersArray) {
        for (let value in this.querysResults) {
            //llama la funcion hasOwnProperty en el objeto queryResults para chekear si tiene la propiedad value
            if (Object.prototype.hasOwnProperty.call(this.querysResults, value)) {
                this.querysResults[value] = { results: undefined, error: undefined }
            }
        }

        for (let thisService of this.servicesComponets) {
            thisService.replaceFilterArray(oldFiltersArray, newFiltersArray);
        }
    }

    @api addBaseFilter() {
        customLog('addBaseFilter');
    }

    @api clearAllFilters() {
        customLog('clearAllFilters');
    }

    @api clearAllTemporaryFilters() {
        customLog('clearTemporaryFilters');
        for (let value in this.querysResults) {
            if (Object.prototype.hasOwnProperty.call(this.querysResults, value)) {
                this.querysResults[value] = { results: undefined, error: undefined }
            }
        }

        for (let thisService of this.servicesComponets) {
            thisService.clearTemporaryFilters();
        }
    }

    @api
    getSaqlStatementForMC () {
        //agarro uno cualquiera:
        return this.servicesComponets[0].getSaqlStatementForMC();
    }

    handleQueryData(e) {
        customLog('manager, data: ', JSON.stringify(e.detail))
        this.querysResults[e.detail.key].results = e.detail.results;

        let errorPrevio = false;

        for (let value in this.querysResults) {
            if (this.querysResults[value].error !== undefined) { errorPrevio = true }
            if (this.querysResults[value].results === undefined && this.querysResults[value].error === undefined) { return }
        }

        let tempObject = { ...this.querysResults };

        if (errorPrevio) {
            const queryErrorEvent = new CustomEvent('queryerror', { detail: tempObject });
            this.dispatchEvent(queryErrorEvent);
            return
        }

        const queryDataEvent = new CustomEvent('querydata', { detail: tempObject });
        this.dispatchEvent(queryDataEvent);
    }

    handleQueryError(e) {
        console.log('manager, error: ', JSON.stringify(e.detail))
        this.querysResults[e.detail.key].error = e.detail.errorMsj;
        for (let value in this.querysResults) {
            if (this.querysResults[value].results === undefined && this.querysResults[value].error === undefined) return;
        }
        let tempObject = { ...this.querysResults };
        const queryErrorEvent = new CustomEvent('queryerror', { detail: tempObject });
        this.dispatchEvent(queryErrorEvent);
    }

    @wire(getDataset, { datasetIdOrApiName: '$param_dataset_name' })
    onGetDataset({ data, error }) {
        if (error) {
            console.log('analyticsManagerTerritory getDataSet error:', JSON.stringify(error));
        } else if (data) {
            this.param_data_set = data.id;
            this.param_data_set_version = data.currentVersionId;
            customLog('analyticsManagerTerritory getDataSet data:');
        }
    }

}