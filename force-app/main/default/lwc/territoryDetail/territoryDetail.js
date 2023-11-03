import { LightningElement, api, track } from 'lwc';
import retrieveTerritory from '@salesforce/apex/TerritoryDetailController.retrieveTerritory';
import createLog from '@salesforce/apex/TerritoryFullPageController_lt.createLog';

import Resources from '@salesforce/resourceUrl/PRM';
import { loadStyle } from 'lightning/platformResourceLoader';

import lblInhabitants from '@salesforce/label/c.PRM_Inhabitants';
import lblWomen from '@salesforce/label/c.PRM_Women';
import lblMen from '@salesforce/label/c.PRM_Men';
import lblEducationLevel from '@salesforce/label/c.PRM_Education_Level';
import lblIncomeRange from '@salesforce/label/c.PRM_Income_Range';
import lblOccupationType from '@salesforce/label/c.PRM_Occupation_Type';
import lblEconomicActivities from '@salesforce/label/c.PRM_Economic_Activities';
import lblGeographicDistribution from '@salesforce/label/c.PRM_Greographic_Distribution';
import lblTerritory from '@salesforce/label/c.PRM_Territory';
import lblAdministrativeLevel from '@salesforce/label/c.PRM_Administrative_Level';
import lblParentTerritory from '@salesforce/label/c.PRM_Parent_Territory';

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}
         
export default class TerritoryDetail extends LightningElement {
    recordcount = 5;
    
    @api recordId;    
    @api community;
    @api makeLogs;

    @track territoryInfo = {};
    @track geographicdistributions = [];
    @track isgeographicdistributionsbuttonvisible = false;
    @track title = '';
    @track subtitle = '';
    @track subtitlelinktext = '';
    @track subtitlelinkurl = '';
    @track iconPeople = '';
    @track renderEducation = false;
    @track renderIncomeRange = false;
    @track renderOccupationType = false;
    @track renderEconomicActivities = false;
    @track lstEconomicActivities = [];


    label = {
        lblInhabitants,
        lblWomen,
        lblMen,
        lblEducationLevel,
        lblIncomeRange,
        lblOccupationType,
        lblEconomicActivities,
        lblGeographicDistribution,
        lblTerritory,
        lblAdministrativeLevel,
        lblParentTerritory
    };

    connectedCallback() {
        if(this.makeLogs){
            createLog({recordId:this.recordId})
            .catch(error=>customLog('Ocurrio un error al intentar crear el log de la busqueda.').forceLog());
        }
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, Resources + '/Prosumia/css/Prosumia.css')
        ])          
    
        this.showsections = (this.PROFILE !== 'Ecuador');
        console.log('test')
        if(this.recordId !== undefined && this.recordId !== null && this.territoryInfo.total === undefined ) {
            retrieveTerritory({ strTerritoryId : this.recordId,
                                strCommunity : this.community 
            }).then(result => {
                this.territoryInfo = result;

                this.renderEducation = this.territoryInfo.educationLevels.length > 0;
                this.renderIncomeRange = this.territoryInfo.incomeranges.length > 0;;
                this.renderOccupationType = this.territoryInfo.occupationTypes.length > 0;
                this.renderEconomicActivities = this.territoryInfo.economicactivities.length > 0;

                if(this.renderEducation || this.renderIncomeRange || this.renderOccupationType || this.renderEconomicActivities ) {
                    this.renderEducation = true;
                    this.renderIncomeRange = true;
                    this.renderOccupationType = true;
                    this.renderEconomicActivities = true;                        
                }


                console.log("Actividades Economicas : ", this.territoryInfo.economicactivities);
                for (var ea of this.territoryInfo.economicactivities) {
                    this.lstEconomicActivities.push({"image": ea.info.image, "value": ea.info.value, "name": ea.info.name, "description": ea.info.description});
                }
                this.lstEconomicActivities.sort(function(a,b){return parseInt(b.value.replaceAll('.','')) - parseInt(a.value.replaceAll('.',''))});


                if(this.territoryInfo.geographicdistributions !== undefined && this.territoryInfo.geographicdistributions !== null) {
                    if(this.territoryInfo.geographicdistributions.length > this.recordcount) {
                        console.log('porque pasa 3 veces!');
                        console.log(this.territoryInfo.geographicdistributions);
                        this.geographicdistributions = this.territoryInfo.geographicdistributions.slice(0, this.recordcount);
                        this.isgeographicdistributionsbuttonvisible = true; 
                    } else {
                        this.isgeographicdistributionsbuttonvisible = false;
                        this.geographicdistributions = this.territoryInfo.geographicdistributions; 
                    }
                }

                this.iconPeople = Resources + '/' + this.community + '/img/IconPeople.png';

                this.title = this.territoryInfo.name;
                
                if(this.territoryInfo.parentid !== undefined && this.territoryInfo.parentid !== null && this.territoryInfo.parentid.length > 0) {
                    this.subtitle = this.label.lblTerritory + ',  ' + this.label.lblAdministrativeLevel + ' ' + this.territoryInfo.administrativelevel + ', ' + this.label.lblParentTerritory;
                    this.subtitlelinktext = this.territoryInfo.parent;
                    
                    this.subtitlelinkurl = this.territoryInfo.parentlink;
                } else {
                    this.subtitle = this.label.lblTerritory + ', ' + this.label.lblAdministrativeLevel + ' ' + this.territoryInfo.administrativelevel;
                }
            }).catch(
                console.log('catch')
            );
        }
        console.log('fin');
    };
    showMoreGeographicDistribution(){
        this.recordcount += 10; 
        if(this.territoryInfo.geographicdistributions !== undefined && this.territoryInfo.geographicdistributions !== null) {
            if(this.territoryInfo.geographicdistributions.length > this.recordcount) {
                this.isgeographicdistributionsbuttonvisible = true;
                this.geographicdistributions = this.territoryInfo.geographicdistributions.slice(0, this.recordcount); 
            } else {
                this.isgeographicdistributionsbuttonvisible = false;
                this.geographicdistributions = this.territoryInfo.geographicdistributions; 
            }
        }
    }
}