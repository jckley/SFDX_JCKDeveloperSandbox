import { LightningElement,api,track,wire } from 'lwc';
import retrieveInteractions from '@salesforce/apex/Pilar360Controller.retrieveInteractions';
import retrievePrograms from '@salesforce/apex/Pilar360Controller.retrievePrograms';
import confirmCitizenInSalesforce from '@salesforce/apex/PRM_Cuidarnos.confirmCitizenInSalesforce';

export default class pilar360Table extends LightningElement {

    @api citizenid;
    @track interactions = [];
    @track error;
    @track programs = [{ label: 'Todos los Programas', value: 'todos' }];
    @track totalInteractions;

    @track totalPages = 1;
    @track pages = [];
    @track currentPage = 1;
    @track firstPage = 1;
    @track lastPage = '';
    cantidadItemsPorPagina = 10;
    @track firstRecord = 0;
    @track lastRecord = 0;
    @track interactionDescript;
    @track hasInteractions;
    
    orderValue = 'reciente';
    // para las fechas personalizadas
    today = new Date();
    @track start_date;
    @track end_date;
    @track range;
    @track datesValuePersonalize;

    iconReciente = "▲";
    iconAntiguo = "▼";
    iconDate;

    @track programValue = 'todos';
    @track dateValue = 'todas'

    get dates() {
        return [
            { label: 'Cualquier fecha', value: 'todas' },
            { label: 'Última semana', value: 'week' },
            { label: 'Último mes', value: 'month' },
            { label: 'Últimos 6 meses', value: '6months' },
            { label: 'Intervalo Personalizado', value: 'personalize' },
        ];
    }

    calculateFirstRecord(){
        this.firstRecord = Math.min((Math.max((this.currentPage-1),0)*this.cantidadItemsPorPagina) + 1, this.totalInteractions);
    }

    calculateLastRecord(){;
        this.lastRecord = Math.min(this.currentPage*this.cantidadItemsPorPagina, this.totalInteractions);
    }

    calculateLastPage(){
        if(this.totalPages==this.firstPage)
            this.lastPage = '';
        else this.lastPage = this.totalPages;
    }

    calculateTotalPages(){
        this.totalPages = Math.max(Math.ceil(this.totalInteractions/this.cantidadItemsPorPagina),1);
    }

    calculatePages(){
        this.calculateTotalPages();
        this.pages=[];
        for(var varNumber = Math.max(this.currentPage-2, 1); varNumber <= Math.min(this.currentPage+2, this.totalPages); varNumber++) {
            if(varNumber == this.currentPage){
                this.pages.push({
                    value: varNumber,
                    active: 'active'
                });
            } else {
                this.pages.push({
                    value: varNumber,
                    active: ''
                });
            }
        }
    }

    handleChangeCurrentPage(event){
        this.currentPage=event.target.name;
        if(this.currentPage === undefined){
            this.currentPage=1;
        }
        this.calculatePaginator();
    }

    calculateInteractionDescript(){
        if(this.totalInteractions==1){
            this.interactionDescript = "interacción";
        } else this.interactionDescript = "interacciones";
    }

    defineInteractionsVisibles(){
        let contador=0;
        this.interactions.forEach(a => {
            if(a.Display == 'slds-border_top'){
                contador+=1;
                let page=Math.ceil(contador/this.cantidadItemsPorPagina);
                a.page=page;
                if(a.page != this.currentPage){
                    a.Display='invisible';
                }
            }
        });
    }

    refreshInteractions(){
        this.totalInteractions=0;
        this.interactions.forEach(a => {
            if((a.Programs__c==this.programValue || this.programValue=='todos')
                && (this.meetsConditionDate(a.Interaction_Date__c) || this.dateValue=='todas')){
                    a.Display = 'slds-border_top';
                    this.totalInteractions+=1;
                    // console.log(this.totalInteractions);
                }
            else a.Display = 'invisible';
        });
    }

    calculatePaginator(){
        this.calculateInteractionDescript();
        this.refreshInteractions();
        this.defineInteractionsVisibles();
        this.calculateFirstRecord();
        this.calculateLastRecord();
        this.calculatePages();
    }

    handleChangePrograms(event) {
        this.programValue = event.currentTarget.value;
        this.currentPage = 1;
        this.totalInteractions = 0;
        this.interactions.forEach(a => {
            if(a.Programs__c!=this.programValue && this.programValue.value!='todos'){
                a.Display='invisible';
            } else {
                a.Display='slds-border_top';
                this.totalInteractions+=1;
            }
        });
        this.calculatePaginator();
    }

    meetsConditionDate(interactionDate){
        if(this.dateValue == 'week' && this.outOfRange(interactionDate, this.previousDate(7)))
            return false;
        else if(this.dateValue == 'month' && this.outOfRange(interactionDate, this.previousDate(30)))
            return false;
        else if(this.dateValue == '6months' && this.outOfRange(interactionDate, this.previousDate(180)))
            return false;
        else if(this.dateValue == 'personalize')
            return this.dateInRange(interactionDate);
        else
            return true;
    }

    handleChangeDates(event) {
        this.dateValue = event.currentTarget.value;
        this.currentPage = 1;
        this.totalInteractions = 0;
        this.interactions.forEach(a => {
            // console.log('previous week: ' + new Date(this.previousDate(7)));
            // console.log('interaction: ' + new Date(a.Interaction_Date__c));
            if(this.dateValue == 'week' && this.outOfRange(a.Interaction_Date__c, this.previousDate(7))){
                a.Display='invisible';
            } else if(this.dateValue == 'month' && this.outOfRange(a.Interaction_Date__c, this.previousDate(30))){
                a.Display='invisible';
            } else if(this.dateValue == '6months' &&  this.outOfRange(a.Interaction_Date__c, this.previousDate(180))){
                a.Display='invisible';
            } else {
                a.Display='slds-border_top';
                this.totalInteractions+=1;
            }
        });

        if(this.dateValue == 'personalize'){
            this.datesValuePersonalize=true;
            this.modifyPersonalizeDate();
        } else {
            this.datesValuePersonalize=false;
            this.calculatePaginator();
        }
        
    }

    modifyPersonalizeDate(){
        this.totalInteractions = 0;
        this.interactions.forEach(a => {
            if(this.dateInRange(a.Interaction_Date__c)){
                a.Display='slds-border_top';
                this.totalInteractions+=1;
            } else {
                a.Display='invisible';
            }
        });
        this.calculatePaginator();
    }

    dateInRange(customDate) {
        return ((new Date(customDate).getTime() >= new Date(this.start_date).getTime()) && (new Date(customDate).getTime() <= new Date(this.end_date).getTime()));
    }

    outOfRange(customDate, limitDate){
        let today = Date.now();
        let customTime = new Date(customDate).getTime();
        let limitTime = new Date(limitDate).getTime();
        let todayX = today < customTime;
        let limitY = limitTime > customTime;
        return limitY || todayX;
    }

    previousDate = (day) => {
        return Math.ceil(this.today - (1000 * 60 * 60 * 24 * day));
    }

    // MÉTODOS PARA EL ORDEN POR FECHAS
    handleChangeOrderDate(event){
        if(this.orderValue == 'reciente')
            this.antiguo();
        else if(this.orderValue == 'antiguo')
            this.reciente();
    }

    reciente(){
        this.orderValue = 'reciente';
        this.iconDate = this.iconReciente;
        this.interactions.sort((a, b) => {
            return new Date(b.Interaction_Date__c).getTime() - 
                new Date(a.Interaction_Date__c).getTime()
        });
    }

    antiguo() {
        this.orderValue = 'antiguo';
        this.iconDate = this.iconAntiguo;
        this.interactions.sort((a, b) => {
            return new Date(a.Interaction_Date__c).getTime() - 
                new Date(b.Interaction_Date__c).getTime()
        });
    }

    async connectedCallback(citizenid) {
        console.log('pilar360Table In connectedCallback()...');
        retrieveInteractions({'id' : this.citizenid})
            .then(result => {
                this.totalInteractions = 0;
                result.forEach(res => {
                    // console.log('interactions resul: ' + res.Programs__c);
                    this.totalInteractions += 1;
                    this.interactions.push({ 
                        id: res.id, 
                        Interaction_Date__c: res.Interaction_Date__c, 
                        Name: res.Name, 
                        Pilar360Citizen_SFID__c: res.Pilar360Citizen_SFID__c, 
                        PilarCiudadanoID__c: res.PilarCiudadanoID__c, 
                        Programs__c: res.Programs__c, 
                        Services__c: res.Services__c, 
                        Display: 'slds-border_top',
                        page: 1
                    });
                });
                if(this.totalInteractions>0)
                    this.hasInteractions = '';
                else
                    this.hasInteractions = 'display:none;';
                this.error = undefined;
                this.calculatePaginator();
            })
            .catch(error => {
                this.interactions = undefined;
                this.error = error;
            });
        
            retrievePrograms()
            .then(result => {
                result.forEach(res => {
                    console.log('programs resul: ' + res);
                    this.programs.push({ label: res, value: res });
                });
                console.log('programs: ');
                console.log(this.programs);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                console.log('error en retrievePrograms: ');
                console.log(this.error);
            });

        this.reciente();

        //para las fechas personalizadas
        this.start_date = (this.start_date) ? this.start_date : this.today.toJSON().slice(0,10);
        this.end_date = (this.end_date) ? this.end_date : this.addDays(this.today,1).toJSON().slice(0,10);
        this.range = this.diff(this.start_date,this.end_date);
    }

    //para las fechas personalizadas
    addDays = (sd,days) => {
        const d = new Date(Number(sd));
        d.setDate(sd.getDate() + days);
        return d;
    }

    diff = (sdate,edate) => {
        let diffTime = Math.abs(new Date(edate).getTime() - new Date(sdate).getTime());
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }

    valid_date = (sdate,edate) => {
        return new Date(edate) >= new Date(sdate);
    }

    handleDateChange = (evt) => {
        let field_name = evt.target.name;
        let inputfield = this.template.querySelector("."+field_name);

        if(field_name === 'startdate')
            this.start_date = evt.target.value; 
        if(field_name === 'enddate')
            this.end_date = evt.target.value; 

        if(this.valid_date(this.start_date,this.end_date) === true){
            inputfield.setCustomValidity('');
            this.range = this.diff(this.start_date,this.end_date);
            this.modifyPersonalizeDate();
        }else{
            inputfield.setCustomValidity('La fecha final debe ser mayor que la fecha de inicio'); 
            
        }
        inputfield.reportValidity();
    }

}