import { LightningElement } from 'lwc';
import getDominios from '@salesforce/apex/prosumer_gestor_dominiosController.getDominios';
import insertDominio from '@salesforce/apex/prosumer_gestor_dominiosController.insertDominio';
import deleteDominio from '@salesforce/apex/prosumer_gestor_dominiosController.deleteDominio';

export default class Prosumer_gestor_dominios extends LightningElement {

    _listDominios;

    get listDominios () {
        if(!this._listDominios){
            return [];
        }
        const tempArray = this._listDominios.map(thisDominio=>{
            return {
                ...thisDominio,
                estadoDominio: thisDominio.Dominio_Verificado__c ? 'Dominio Verificado' : 'Pendiente Verificar'
            }
        })
        
        const orderArray = tempArray.sort((a,b)=>{
            //googleo machaso como ordenar los boolean
            return b.Dominio_Verificado__c - a.Dominio_Verificado__c  
        })

        return orderArray;
    }

    connectedCallback() {
        getDominios()
            .then(response => {
                this._listDominios = response;
            })
            .catch(error => {
                console.log('Paso algo en prosumer_gestor_dominiosController getDominios: ', error);
            })
    }

    handleNuevoDominio() {
        console.log('handleNuevoDominio')
        const mailformat = /^@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        const dominioParaVerificar = this.nuevoDominioValue;
        if(dominioParaVerificar.match(mailformat)){
            insertDominio({dominio:dominioParaVerificar})
                .then(nuevoDominio=>{
                    this._listDominios = [...this._listDominios, nuevoDominio];
                })
                .catch(error=>{
                    console.log('Paso algo en prosumer_gestor_dominiosController insertDominio: ', error);
                })
            return
        }
        console.log('no paso la regex')
        const inputCmp = this.template.querySelector('.inputCmp');
        inputCmp.setCustomValidity('Ingrese un dominio valido. Tiene que arrancar con @');
        inputCmp.reportValidity()
    }

    nuevoDominioValue;
    handleNuevoDominioValueChange (event) {
        this.nuevoDominioValue = event.detail.value;
        const inputCmp = event.currentTarget;
        inputCmp.setCustomValidity("");
        inputCmp.reportValidity();
    }
}