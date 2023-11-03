import { LightningElement, api, wire } from 'lwc';
import { getDataset } from 'lightning/analyticsWaveApi';

//el componente tiene la logica para manejar colecciones de analyticsServices.
// Puntualmente las que hacen las querys de para territoryDetail 

const OTHERS_QUERYS = [
    { actKey: 'Gender', queryDefinition: 'BY_GENDER' },
    { actKey: 'Ages', queryDefinition: 'BY_AGES' },
    { actKey: 'Ingreso', queryDefinition: 'BY_INGRESO' },
    { actKey: 'Education', queryDefinition: 'BY_EDUCATION' },
    { actKey: 'ChildTerritories', queryDefinition: 'BY_CHILD_TERRITORY' },
    { actKey: 'ActEco' ,queryDefinition: 'BY_ACTIVIDAD_ECONOMICA'},
    { actKey: 'TipoOcu' ,queryDefinition: 'BY_OCUPACION'}
]


const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) return;
    customLog(...stringsToLog);
}

export default class AnalyticsManagerTerritory extends LightningElement {

    @api param_child_level_name;
    @api param_child_level_id;

    @api param_territory_id;

    @api param_dataset_name;
    //default: 'TerritoryFullPage_DS'


    get territoryBaseFilter() {
        return {
            filterField: 'fx_TerritoryTree',
            filterComparisonOperator: 'like',
            filterComparisonValue: `"%${this.param_territory_id}%"`
        }
    };

    param_data_set;
    param_data_set_version;

    querysToDo = [];

    querysResults = {};

    _servicesComponets
    get servicesComponets() {
        if (!this._servicesComponets) {
            this._servicesComponets = this.template.querySelectorAll('c-analytics-service')
        }
        return this._servicesComponets;
    }

    connectedCallback() {
        customLog('iniciando analitycs manager');
        customLog('analitycs manager basefilter: ', JSON.stringify(this.territoryBaseFilter));

        OTHERS_QUERYS.forEach(thisQuery => {
            if (thisQuery.queryDefinition === 'BY_CHILD_TERRITORY' && !this.param_child_level_name) return
            this.querysResults[thisQuery.actKey] = { results: undefined, error: undefined };
        })

        let tempOthers = OTHERS_QUERYS.map(thisQuery => {
            return {
                key: thisQuery.actKey,
                baseFilters: {
                    filterArray: [
                        this.territoryBaseFilter
                    ],
                    filterLogicalOperator: "&&"
                },
                queryDefinition: thisQuery.queryDefinition
            }
        });

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
            if (Object.prototype.hasOwnProperty.call(this.querysResults, value)) {
                this.querysResults[value] = { results: undefined, error: undefined }
            }
        }

        for (let thisService of this.servicesComponets) {
            thisService.toggleTemporaryFilter(filter);
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