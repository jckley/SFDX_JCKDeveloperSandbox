import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCampanias from '@salesforce/apex/Prosumer_DashboardController.getCampanias';
import RESOURCES from '@salesforce/resourceUrl/prosumerSendSMS'


export default class Prosumer_dashboard extends NavigationMixin(LightningElement) {

    error = RESOURCES + "/error.png";
    preparando = RESOURCES + "/alert.png";
    exito = RESOURCES + "/confirmado.png";

    handleNavigate(event) {

        event.preventDefault();

        const recordToNavigate = event.target.dataset.navigateToId;
        console.log('navigate to: ' + recordToNavigate);



        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordToNavigate,
                objectApiName: 'Campania__c',
                actionName: 'view'
            }
        });

    }


    connectedCallback() {
        console.log('CONECTANDO A CAMPAÑA?!1!')
        getCampanias().then((data) => {
            console.log("data = ", data);
            if (data.length > 0) {
                this.campaigns_list = data.map(thisCampaign => {
                    let tempCampaign = { ...thisCampaign };

                    if (thisCampaign.Prosumer_Estado__c === 'Export en espera de ejecución') {
                        tempCampaign["ExportEspera"] = true;
                    } else if (thisCampaign.Prosumer_Estado__c === 'Export en ejecución') {
                        tempCampaign["ExportEjecucion"] = true;
                    } else if (thisCampaign.Prosumer_Estado__c === 'Export Finalizado OK') {
                        tempCampaign["ExportFinalizado"] = true;
                    } else if (thisCampaign.Prosumer_Estado__c === 'Export Finalizado con Errores') {
                        tempCampaign["ExportError"] = true;
                    } else if (thisCampaign.Prosumer_Estado__c === 'Send Automation Iniciado') {
                        tempCampaign["AutomationIniciado"] = true;
                    } else if (thisCampaign.Prosumer_Estado__c === 'Send Automation en ejecución') {
                        tempCampaign["AutomationEjecucion"] = true;
                    } else if (thisCampaign.Prosumer_Estado__c === 'Cerrado') {
                        tempCampaign["Cerrado"] = true;
                    } else {
                        tempCampaign["Else"] = true;
                    }

                    return tempCampaign;

                });

                let smsCampaings = 0;
                let emailCampaings = 0;
                let ivrCampaings = 0;
                let totalImpactos = 0;

                this.campaigns_list.forEach(thisCampaign => {
                    //no estamos recuperando el tipo desde el controller...
                    smsCampaings = smsCampaings + 1;
                    totalImpactos = totalImpactos + thisCampaign.Prosumer_Moviles_en_Audiencia__c;
                })

                this.smsCampaings = smsCampaings;
                this.emailCampaings = emailCampaings;
                this.ivrCampaings = ivrCampaings;
                this.totalImpactos = totalImpactos;

                this.has_campaigns = true;
                this.number_of_campaings = data.length;
                console.log(this.campaigns_list);
            }
        })
        .catch(error=>{console.log('no puedieron recuperar las campañas : ', JSON.stringify(error))})
    }

    @track campaigns_list = [];
    @track has_campaigns = false;
    @track number_of_campaings = 0;

    smsCampaings = 0;
    emailCampaings = 0;
    ivrCampaings = 0;
    totalImpactos = 0;

    get formatedValues() {
        return {
            totalCampañas: (this.smsCampaings + this.emailCampaings + this.ivrCampaings).toLocaleString('es-AR'),
            smsCampaings: this.smsCampaings.toLocaleString('es-AR'),
            emailCampaings: this.emailCampaings.toLocaleString('es-AR'),
            ivrCampaings: this.ivrCampaings.toLocaleString('es-AR'),
            totalImpactos: this.totalImpactos.toLocaleString('es-AR')
        }
    }

    @track value = 0;

}