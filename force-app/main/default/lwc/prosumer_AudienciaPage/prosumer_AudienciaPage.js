import { LightningElement, wire } from 'lwc';
import { executeQuery } from 'lightning/analyticsWaveApi';
import prosumerSeleccionarAccion from 'c/prosumer_modal_seleccionar_accion';
import { NavigationMixin } from 'lightning/navigation';

import getProsumerAudienceCriterias from '@salesforce/apex/Prosumer_AudienciaPageController.getProsumerAudienceCriterias';
import setSessionCache from '@salesforce/apex/CacheManager.setSessionCache';

const IS_LOG_ENABLED = true;
const DEFAULT_LOG = 'Prosumer, AudienciaPage: ';

function customLog(...stringsToLog) {
    const strArray = [DEFAULT_LOG];
    const completeLog = strArray.concat(stringsToLog);

    //cuando los logs estan activos por default, logeo y retorno null  
    if (IS_LOG_ENABLED) {
        console.log(...completeLog);
        return { forceLog: () => null };
    }
    //cuando no, necesito una funcion para permitir loggear a manopla en algunos lugares    
    return { forceLog: () => console.log(...completeLog) };
}


export default class Prosumer_AudienciaPage extends NavigationMixin(LightningElement) {

    handleScroll() {
        const element = this.template.querySelector('.filterComponent');
        const element2 = this.template.querySelector('.filterComponent .box .body');
        /*const rect = element.getBoundingClientRect();
    
        if (rect.top <= 0 && !this.isSticky) {
          element.classList.add('sticky');
          this.isSticky = true;
        } else if (rect.top > 0 && this.isSticky) {
          element.classList.remove('sticky');
          this.isSticky = false;
        }
    
        const scrollPosition = window.pageYOffset - 1500;
        const maxOpacityPosition = 500; // cambiar aquí para ajustar la posición
        const opacity = Math.min(scrollPosition / maxOpacityPosition, 1);
        element.style.opacity = opacity;*/

        // console.log("scroll>>>>" +window.pageYOffset);

        // console.log("scroll currentH style >>>"+element.style.height);
        let currentHeight = element.style.height;
        // console.log("scroll currentH let>>>"+currentHeight);
        

        if (window.pageYOffset > 35){
            element.style.height = "70px";
            element2.style.height = "70px";

        }else{
            element.style.height = "calc(105px - "+window.pageYOffset+"px";
            element2.style.height = "calc(105px - "+window.pageYOffset+"px";
        }

        
      }

    connectedCallback() {
        window.addEventListener('scroll', this.handleScroll.bind(this));

        getProsumerAudienceCriterias()
            .then(response => {
                this.relatedAccountInfo = response
                customLog('obtencion criterios: ', JSON.stringify(response))
            });
    }

    relatedAccountInfo = null;

    dataFromAnalytics;
    _analitycsManager;
    loadingForNewData = false;

    get analitycsManager() {
        customLog('get analitycsManager')
        if (!this._analitycsManager) {
            this._analitycsManager = this.template.querySelector('c-prosumer_analytics-manager');
        }

        return this._analitycsManager;
    }

    territoryLevelFromList;

    get analitycsManagerParams() {
        if (!this.relatedAccountInfo) return null;

        //en algun punto va a hacer falta armar algo para obtener una primer lista de territorios como base.
        //va a depender de como quieran que se comporte la seccion de seleccion de territorios
        //se podria poner directamente en el Manager? O armar otra query en el service... No se, o directamente en el componente de la seccion
        //pero tendria que recibir el admin lvl
        //if (!this.territoryLt) return undefined

        let base_filters = this.relatedAccountInfo?.SAQL;
        let nivelAdmin = 0;

        if (base_filters) {
            if (base_filters.includes('Level1Name__c') || base_filters.includes('Level1ID__c')) { nivelAdmin = 1 }
            if (base_filters.includes('Level2Name__c') || base_filters.includes('Level2ID__c')) { nivelAdmin = 2 }
            if (base_filters.includes('Level3Name__c') || base_filters.includes('Level3ID__c')) { nivelAdmin = 3 }
        }

        if (this.territoryLevelFromList) {
            nivelAdmin = Number(this.territoryLevelFromList);
        }


        let child_level_name = `Level${nivelAdmin + 1}Name__c`;
        let child_level_id = `Level${nivelAdmin + 1}ID__c`

        let dataset_name = "TerritoryFullPage_DS";



        customLog('Base filters: ', JSON.stringify(base_filters));

        let tempObject = {
            child_level_name,
            child_level_id,
            dataset_name,
            base_filters,
            nivelAdmin
        }

        return tempObject;
    }

    get areManagerParamsReady() {
        const areReady = this.analitycsManagerParams !== null;
        customLog('areReady devuelve: ', areReady);
        return areReady;
    }


    handleQueryData(e) {
        this.dataFromAnalytics = { ...e.detail };
        customLog('handleQueryData: ', JSON.stringify(this.dataFromAnalytics));
        customLog('handleQueryData, datos completos');
        this.loadingForNewData = false;
    }

    get isAnalitycsReady() {
        return Boolean(this.dataFromAnalytics);
    }

    get loadingScreenOn() {
        return (!this.isAnalitycsReady || this.loadingForNewData || !this.areManagerParamsReady)
    }

    handleQueryError(e) {
        customLog('fullterritory_analytics error: ' , JSON.stringify(e.detail)).forceLog();
    }

    handleFilterClickOnComponent(e) {
        this.toggleFilter(e.detail.filterObject, e.detail.label, e.detail.bindedFunction, e.detail.territoryLevel);
    }

    toggleFilter(filter, filterLabel, bindedFunction, territoryLevel) {
        this.loadingForNewData = true;
        if(territoryLevel){
            this.territoryLevelFromList = territoryLevel;
        }
        this.template.querySelector('.filterComponent').toggleFilter({ filterLabel: filterLabel, filterString: JSON.stringify(filter), bindedFunction, territoryLevel });
        this.analitycsManager.toggleTemporaryFilter(filter);
    }

    handleRemoveOneFilter(event) {
        this.loadingForNewData = true;
        const filter = JSON.parse(event.detail.filterString);
        this.analitycsManager.toggleTemporaryFilter(filter);
    }

    handleRemoveTerritories (event) {
        this.loadingForNewData = true;
        this.territoryLevelFromList  = event.detail.levelToSet;
        const oldFiltersList = event.detail.oldFilters;
        const newFiltersList = event.detail.newFilters;
        const fuenteEvento = event.currentTarget.localName;
        if (fuenteEvento === 'c-prosumer_filters') {
            this.template.querySelector('c-prosumer_territories-list').removeFiltersFromList(oldFiltersList);
        }
        if (fuenteEvento === 'c-prosumer_territories-list') {
            this.template.querySelector('c-prosumer_filters').removeFiltersFromList(oldFiltersList);
        }
        this.analitycsManager.replaceFilterArray(oldFiltersList,newFiltersList);
    }

    handleRemoveAllFilters() {
        this.loadingForNewData = true;
        this.territoryLevelFromList = null;
        this.template.querySelector('c-prosumer_territories-list').removeAllLocalFilters();
        this.analitycsManager.clearAllTemporaryFilters();
    }


    queryString = '';

    async handleClickEjectuar() {
        const querys_forMc = this.analitycsManager.getSaqlStatementForMC();
        //{
            //mobilePhoneQuery_forMc,
            //homePhoneQuery_forMc,
            //emailQuery_forMc
        //}
        const queryString = querys_forMc.emailQuery_forMc;
        this.queryString = queryString;
        customLog('Query for check: ', JSON.stringify(queryString));
        customLog('Query mobilePhoneQuery_forMc: ', JSON.stringify(querys_forMc.mobilePhoneQuery_forMc));
        customLog('Query homePhoneQuery_forMc: ', JSON.stringify(querys_forMc.homePhoneQuery_forMc));
        customLog('Query emailQuery_forMc: ', JSON.stringify(querys_forMc.emailQuery_forMc));

        let totalsFromAnalytics = this.dataFromAnalytics?.Counting_All?.results[0] ?? {};

        const totalPersonas = totalsFromAnalytics.Total ?? 0;
        const totalMobiles = totalsFromAnalytics.Countable_TieneMobile ?? 0;
        const totalFijos = totalsFromAnalytics.Countable_TienePhone ?? 0;
        const totalEmails = totalsFromAnalytics.Countable_TieneEmail ?? 0;

        customLog('info para modal: ', totalPersonas).forceLog();

        const result = await prosumerSeleccionarAccion.open({
            size: 'large',
            input_params: {
                number_of_people: totalPersonas,
                number_of_mobiles: totalMobiles,
                number_of_phones: totalFijos,
                number_of_emails: totalEmails,
            },
            label: 'Modal Seleccionar Accion'
        });

        customLog('result: ', result)

        if (!result) return;

        const paramsNextPage = {
            number_of_people: totalPersonas,
            number_of_mobiles: totalMobiles,
            number_of_fijos: totalFijos,
            number_of_emails: totalEmails,
            mobilePhoneQuery_forMc: querys_forMc.mobilePhoneQuery_forMc,
            homePhoneQuery_forMc: querys_forMc.homePhoneQuery_forMc,
            emailQuery_forMc: querys_forMc.emailQuery_forMc,
            type_of_campaign: result,
            filters: this.template.querySelector('.filterComponent').getFiltersLabels()
        }

        const JSONString = JSON.stringify(paramsNextPage);

        setSessionCache({
            key: 'paramsForAudienceLWC',
            value: JSONString
        }).then(response => {
            if (response === JSONString) {
                if (result == 'smsCampaing') {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Nuevo_SMS__c'
                        },
                    });
                }
                if (result == 'ivrCampaignMobile' || result == 'ivrCampaignFijo') {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'nuevo_ivr__c'
                        },
                    });
                }

                if (result == 'emailCampaign') {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Nuevo_email__c'
                        },
                    });
                }
            }
        })
    }


    //ESTO ERA PARA PROBAR QUE LA QUERY RETORNADA POR LA SAQL NO TENGA ERRORES DE SINTAXIS!!!
    @wire(executeQuery, { query: '$queryString' })
    onExecuteQuery({ data, error }) {
        if (error) {
            customLog('SAQL TO DATA EXTENSION ERROR: ', JSON.stringify(error)).forceLog();
        } else if (data) {
            const records = data.results.records;
            customLog('SAQL TO DATA EXTENSION: ', JSON.stringify(records));
        }
    }

}