import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Resources from '@salesforce/resourceUrl/Communities'
import getGroupedEncuestas from '@salesforce/apex/RiverEncuestasController.getGroupedEncuestas';

const ALL_PAGE_COMMUNITY_CLASS = "all-page community";
const ALL_PAGE_CRM_CLASS = "all-page crm"

export default class RiverId_encuestas extends NavigationMixin(LightningElement) {
    @api currentPage;
    isRecordReady = true;

    get all_page_class () {
        return this.currentPage === 'CRM' ? ALL_PAGE_CRM_CLASS : ALL_PAGE_COMMUNITY_CLASS;
    }

    barrasIcon = Resources + '/SALESFORCE/img/encuestas-barras.svg';

    encuestas = [];

    connectedCallback(){
        getGroupedEncuestas()
        .then(data=>{
            this.encuestas = processData(data);
        })
        .catch(error=>console.log('Hubo un error al recuperar las encuestas', JSON.stringify(error)))

        function processData (data) {

            let tempEncuestas = [];
            let uniqueId = 0;

            data.forEach(thisAggregateResult => {
                let tempEncuesta = {};
                tempEncuesta.id = 'Encuestaid' + uniqueId;
                tempEncuesta.name = thisAggregateResult.River_Name__c ? thisAggregateResult.River_Name__c : 'CARP Encuesta';
                tempEncuesta.link = 'pQwnE112/3iOAbJPxotcXTY2o';
                tempEncuesta.respuestas = thisAggregateResult.totalEncuestas;
                tempEncuestas.push(tempEncuesta);
                
                uniqueId ++;
            })

            return tempEncuestas;
        }
    }

    get cantidadEncuestas () {
        return this.encuestas.length;
    }

    navigateTo (event){
        console.log('cliiik event')
        console.log('link: ', event.currentTarget.getAttribute("data-navigateurl"));
        let iframeparam = event.currentTarget.getAttribute("data-navigateurl");
        let urlParams = {iframeparam}
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'iframe'
            },
            state: urlParams
        });
    }

}