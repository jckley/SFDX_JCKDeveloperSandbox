import { LightningElement, api } from 'lwc';
import getCampania from '@salesforce/apex/Prosumer_DashboardController.getCampania';
import RESOURCES from '@salesforce/resourceUrl/prosumerSendSMS';
import { NavigationMixin } from 'lightning/navigation';

export default class Prosumer_Campania extends NavigationMixin(LightningElement) {

    @api recordId;

    campania;

    connectedCallback(){
        getCampania({id: this.recordId}).then(results=>{
            console.log(JSON.stringify (results.Prosumer_Filtros_Audiencia__c));
            const filtrosArray = JSON.parse(results.Prosumer_Filtros_Audiencia__c);
            this.audience_list = filtrosArray;
            this.campania = results;
        });
    }

    get formatedValues () {
        if(!this.campania){return{}}

       
        let valorAsignado;
        let estadoAsignado;

        if (this.campania.Prosumer_Estado__c === 'Export en ejecución') {
            valorAsignado = 30;
            estadoAsignado = "Ejecutando";
        } else if (this.campania.Prosumer_Estado__c === 'Export en espera de ejecución') {
            valorAsignado = 10;
            estadoAsignado = "Preparando";
        } else if (this.campania.Prosumer_Estado__c === 'Export Finalizado OK') {
            valorAsignado = 50;
            estadoAsignado = "Ejecutando";
        } else if (this.campania.Prosumer_Estado__c === 'Send Automation Iniciado') {
            valorAsignado = 70;
            estadoAsignado = "Ejecutando";
        } else if (this.campania.Prosumer_Estado__c === 'Send Automation en ejecución') {
            valorAsignado = 90;
            estadoAsignado = "Ejecutando";
        } else if (this.campania.Prosumer_Estado__c === 'Cerrado') {
            valorAsignado = 100;
            estadoAsignado = "Finalizada";
            const notificacion = this.template.querySelector('.notificacion');
            notificacion.style.opacity = "0";
            notificacion.style.height = "0px";

        } else if (this.campania.Prosumer_Estado__c === 'Export Finalizado con Errores') {
            valorAsignado = 100;
            estadoAsignado = "Fallo campaña";
            const notificacion = this.template.querySelector('.notificacion');
            notificacion.style.opacity = "0";
            notificacion.style.height = "0px";
        }

        return {
            number_of_people:this.campania.Prosumer_Tamanio_de_Audiencia__c.toLocaleString('es-AR'),
            number_of_phones:this.campania.Prosumer_Moviles_en_Audiencia__c.toLocaleString('es-AR'),
            costo_campania:this.campania.Prosumer_Creditos_Campania__c.toLocaleString('es-AR'),
            entregados:this.campania.Prosumer_Cantidad_Entregados__c.toLocaleString('es-AR'),
            noentregados:this.campania.Prosumer_Cantidad_No_Entregados__c.toLocaleString('es-AR'),
            Desde:this.campania.Desde,
            titulo:this.campania.Name,
            estado: estadoAsignado,
            porcentaje: valorAsignado,
            Prosumer_Mensaje_SMS__c: this.campania.Prosumer_Mensaje_SMS__c,
        }
    }

    audience_list = [];

    celular = RESOURCES + "/celular.png"

    atrasimg = RESOURCES + "/atrasflecha.png";

    notificacion = RESOURCES + "/alert.png";

    entregado = RESOURCES + "/entregado.png";

    noentregado = RESOURCES + "/noentregado.png";

    handleAtras () {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Dashboard_Activaciones__c'
            },
        });
    }
}