import { LightningElement,api,track,wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import ICONS from '@salesforce/resourceUrl/IconsPack1';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';

export default class Communities_contactTags extends LightningElement {

    @api recordId;
    @track record;
    @track community_site;
    @track error;
    @track tagsAudienciaPolitica;
    @track tagsAudienciaElectoral;
    @track tagsAudienciaGeneraciones;
    @track tagsActividadesEconomicas;
    @track tagsCommunity;
    @track tagsCDPAxis;
    @track tagsCDPCampaign;
    @track tagsCDPScore;
    @track tagsCDPStatus;
    @track tagsEPDLG;
    @track tagsSituacionAsalariado;
    @track tagsJerarquiaEmpleo;

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.doLoadContactData();
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.record = undefined;
        }
    }

    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.community_site = data;
            this.error = undefined;
            this.doLoadStyles();
            this.iconAddress = ICONS + '/img/KUhouse_lb.svg';
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.community_site = undefined;
        }
    }

    doLoadStyles(){
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactAddress.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    doLoadContactData(){

        // this.tags = '#' + this.record.tagsForCommunity;
        if(this.record.hashTags.tagsActividadesEconomicas.tagsSelected){
            this.tagsActividadesEconomicas = this.record.hashTags.tagsActividadesEconomicas.tagsSelected;
            console.log('actividades económicas: ' + this.record.hashTags.tagsActividadesEconomicas.tagsSelected.length);
        }
        
        if(this.record.hashTags.tagsAudienciaPolitica.tagsSelected){
            this.tagsAudienciaPolitica = this.record.hashTags.tagsAudienciaPolitica.tagsSelected;
            console.log('audiencia politica: ' + this.record.hashTags.tagsAudienciaPolitica.tagsSelected.length);
        }
        
        if(this.record.hashTags.tagsAudienciaElectoral.tagsSelected){
            this.tagsAudienciaElectoral = this.record.hashTags.tagsAudienciaElectoral.tagsSelected;
            console.log('audiencia electoral: ' + this.record.hashTags.tagsAudienciaElectoral.tagsSelected.length);
        }

        if(this.record.hashTags.tagsAudienciaGeneraciones.tagsSelected){
            this.tagsAudienciaGeneraciones = this.record.hashTags.tagsAudienciaGeneraciones.tagsSelected;
            console.log('audiencia generaciones: ' + this.record.hashTags.tagsAudienciaGeneraciones.tagsSelected.length);
        }
        
        if(this.record.hashTags.tagsCommunity.tagsSelected){
            this.tagsCommunity = this.record.hashTags.tagsCommunity.tagsSelected;
            console.log('comunidad: ' + this.record.hashTags.tagsCommunity.tagsSelected.length);
        }

        if(this.record.hashTags.tagsCDPAxis.tagsSelected){
            this.tagsCDPAxis = this.record.hashTags.tagsCDPAxis.tagsSelected;
            console.log('tagsCDPAxis: ' + this.record.hashTags.tagsCDPAxis.tagsSelected.length);
        }

        if(this.record.hashTags.tagsCDPCampaign.tagsSelected){
            this.tagsCDPCampaign = this.record.hashTags.tagsCDPCampaign.tagsSelected;
            console.log('tagsCDPCampaign: ' + this.record.hashTags.tagsCDPCampaign.tagsSelected.length);
        }

        if(this.record.hashTags.tagsCDPScore.tagsSelected){
            this.tagsCDPScore = this.record.hashTags.tagsCDPScore.tagsSelected;
            console.log('tagsCDPScore: ' + this.record.hashTags.tagsCDPScore.tagsSelected.length);
        }

        if(this.record.hashTags.tagsCDPStatus.tagsSelected){
            this.tagsCDPStatus = this.record.hashTags.tagsCDPStatus.tagsSelected;
            console.log('tagsCDPStatus: ' + this.record.hashTags.tagsCDPStatus.tagsSelected.length);
        }

        if(this.record.hashTags.tagsEPDLG.tagsSelected){
            this.tagsEPDLG = this.record.hashTags.tagsEPDLG.tagsSelected;
            console.log('tagsEPDLG: ' + this.record.hashTags.tagsEPDLG.tagsSelected.length);
        }

        if(this.record.hashTags.tagsSituacionAsalariado.tagsSelected){
            this.tagsSituacionAsalariado = this.record.hashTags.tagsSituacionAsalariado.tagsSelected;
            console.log('tagsSituacionAsalariado: ' + this.record.hashTags.tagsSituacionAsalariado.tagsSelected.length);
        }

        // if(this.record.hashTags.tagsJerarquiaEmpleo.tagsSelected){
        //     this.tagsJerarquiaEmpleo = this.record.hashTags.tagsJerarquiaEmpleo.tagsSelected;
        //     console.log('tagsJerarquiaEmpleo: ' + this.record.hashTags.tagsJerarquiaEmpleo.tagsSelected.length);
        // }
        
    }

    get tagsActividadesEconomicasLength(){
        return this.tagsActividadesEconomicas.length>0;
    }

    get tagsAudienciaPoliticaLength(){
        return this.tagsAudienciaPolitica.length>0;
    }

    get tagsAudienciaElectoralLength(){
        return this.tagsAudienciaElectoral.length>0;
    }

    get tagsAudienciaGeneracionesLength(){
        return this.tagsAudienciaGeneraciones.length>0;
    }
    
    get tagsCommunityLength(){
        return this.tagsCommunity.length>0;
    }

    get tagsCDPAxisLength(){
        return this.tagsCDPAxis.length>0;
    }
    
    get tagsCDPCampaignLength(){
        return this.tagsCDPCampaign.length>0;
    }
    
    get tagsCDPScoreLength(){
        return this.tagsCDPScore.length>0;
    }

    get tagsCDPStatusLength(){
        return this.tagsCDPStatus.length>0;
    }
    
    get tagsEPDLGLength(){
        return this.tagsEPDLG.length>0;
    }
    
    get tagsSituacionAsalariadoLength(){
        return this.tagsSituacionAsalariado.length>0;
    }

}