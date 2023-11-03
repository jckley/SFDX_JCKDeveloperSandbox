import { LightningElement, api, track } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';

import Resources from '@salesforce/resourceUrl/MiMuniIcons';
import retrieveStats from '@salesforce/apex/Pilar360Controller.retrieveStats'
import retrievePilarRecord from '@salesforce/apex/Pilar360Controller.retrievePilarRecord'


export default class Newcom_mimuniCharts extends LightningElement {

    // iconSalud    = Resources + '/salud.svg';
    // iconBarrio   = Resources + '/barrio.svg';
    // iconLicencia = Resources + '/licencia.svg';
    // iconMascota  = Resources + '/mascota.svg';
    // iconWifi     = Resources + '/wifi.svg';
    // iconOtros    = Resources + '/wifi.svg';

    isChartJsInitialized = false;

    @api citizenid;

    @track misalud    = {programa: 'MiSalud'   , cant: 0, percent: 0, icon: Resources + '/salud.svg'   , interactions: []};
    @track mibarrio   = {programa: 'MiBarrio'  , cant: 0, percent: 0, icon: Resources + '/barrio.svg'  , interactions: []};
    @track milicencia = {programa: 'MiDocumentacion', cant: 0, percent: 0, icon: Resources + '/licencia.svg', interactions: []};
    @track mimascota  = {programa: 'MiMascota' , cant: 0, percent: 0, icon: Resources + '/mascota.svg' , interactions: []};
    @track miwifi     = {programa: 'MiWifi'    , cant: 0, percent: 0, icon: Resources + '/wifi.svg'    , interactions: []};
    @track miotros    = {programa: 'Otros'     , cant: 0, percent: 0, icon: Resources + '/otros.svg'    , interactions: []};
    @track sumainteracciones = 0;
    @track totalInteractions;
    @track hasInteractions;

    @track citizenName;

    @track interactions = [this.misalud, this.mibarrio, this.milicencia, this.mimascota, this.miwifi, this.miotros];

    connectedCallback() {
        console.log("connectedCallback");
    }

    disconnectedCallback() {
        console.log("disconnectedCallback");
    }

    handleRetrievePilarRecord(citizenId) {
        console.log("handleRetrievePilarRecord!!!!");
        retrievePilarRecord({'id' : citizenId})
        .then(data => {
            console.log("DATA : ", data);
            this.citizenName = data.Citizen__r.Name;
        }).catch(error => {
            console.log(error);
        });
    }


    handleRetrieveStats(citizenId) {
        console.log("retrieveStats!!!!");
 
        retrieveStats({'id' : citizenId})
        .then(data => {
            this.totalInteractions=0;
            console.log(data);
            data.forEach(d => {
                this.totalInteractions += 1;
                // console.log('interacion +1');
                if (d.Programs__c.includes('Salud'))
                {
                    // this.interactions.misalud.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                    this.sumainteracciones += d.expr0;
                    this.misalud.cant += d.expr0;
                    this.misalud.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                }
                if (d.Programs__c.includes('Barrio'))
                {
                    this.sumainteracciones += d.expr0;
                    this.mibarrio.cant += d.expr0;
                    this.mibarrio.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                }
                if (d.Programs__c.includes('Documentacion'))
                {
                    this.sumainteracciones += d.expr0;
                    this.milicencia.cant += d.expr0;
                    this.milicencia.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                }
                if (d.Programs__c.includes('Mascota'))
                {
                    this.sumainteracciones += d.expr0;
                    this.mimascota.cant += d.expr0;
                    this.mimascota.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                }
                if (d.Programs__c.includes('WIFI'))
                {
                    this.sumainteracciones += d.expr0;
                    this.miwifi.cant += d.expr0;
                    this.miwifi.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                }
                if (d.Programs__c.includes('Otros'))
                {
                    this.sumainteracciones += d.expr0;
                    this.miotros.cant += d.expr0;
                    this.miotros.interactions.push({Programa: d.Programs__c, Servicio: d.Services__c, Stats: d.expr0});
                }
            });

            this.misalud.percent    = Math.round(100.0 * this.misalud.cant    / Math.max(this.sumainteracciones, 1.0));
            this.mibarrio.percent   = Math.round(100.0 * this.mibarrio.cant   / Math.max(this.sumainteracciones, 1.0));
            this.milicencia.percent = Math.round(100.0 * this.milicencia.cant / Math.max(this.sumainteracciones, 1.0));
            this.mimascota.percent  = Math.round(100.0 * this.mimascota.cant  / Math.max(this.sumainteracciones, 1.0));
            this.miwifi.percent     = Math.round(100.0 * this.miwifi.cant     / Math.max(this.sumainteracciones, 1.0));
            this.miotros.percent    = Math.round(100.0 * this.miotros.cant    / Math.max(this.sumainteracciones, 1.0));

            let max_percent = Math.max(this.misalud.percent, this.mibarrio.percent, this.milicencia.percent, this.mimascota.percent, this.miwifi.percent, this.miotros.percent);
            if (max_percent == this.misalud.percent)
                this.misalud.percent = 100 - this.mibarrio.percent - this.milicencia.percent - this.mimascota.percent - this.miwifi.percent - this.miotros.percent;
            else if (max_percent == this.mibarrio.percent)
                this.barrio.percent = 100 - this.misalud.percent - this.milicencia.percent - this.mimascota.percent - this.miwifi.percent - this.miotros.percent;
            else if (max_percent == this.milicencia.percent)
                this.milicencia.percent = 100 - this.misalud.percent - this.mibarrio.percent - this.mimascota.percent - this.miwifi.percent - this.miotros.percent;
            else if (max_percent == this.mimascota.percent)
                this.mimascota.percent = 100 - this.misalud.percent - this.mibarrio.percent - this.milicencia.percent - this.miwifi.percent - this.miotros.percent;
            else if (max_percent == this.miwifi.percent)
                this.miwifi.percent = 100 - this.misalud.percent - this.mibarrio.percent - this.milicencia.percent - this.mimascota.percent - this.miotros.percent;
            else if (max_percent == this.miotros.percent)
                this.miotros.percent = 100 - this.misalud.percent - this.mibarrio.percent - this.milicencia.percent - this.mimascota.percent - this.miwifi.percent;


            if(this.totalInteractions>0)
                this.hasInteractions = '';
            else
                this.hasInteractions = 'display:none;';
                
            this.mainChart();
            this.healthChart();
            this.contactsChart();
            this.box3Chart();
            this.box4Chart();
            this.box5Chart();
            this.box6Chart();
        }).catch(error => {
            console.log(error);
        });

    }

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }

        // load chartjs from the static resource
        loadScript(this, chartjs + '/Chart.bundle.min.js')
            .then(() => {
                this.isChartJsInitialized = true;
                this.handleRetrieveStats(this.citizenid);
                this.handleRetrievePilarRecord(this.citizenid);
            })
            .catch(error => console.log(error));
    }

    mainChart() {
        const data = {
            labels: [this.milicencia.programa, this.mimascota.programa, this.misalud.programa, this.miwifi.programa, this.mibarrio.programa, this.miotros.programa],
            datasets: [{
                // label: [],
                data: [this.milicencia.cant, this.mimascota.cant, this.misalud.cant, this.miwifi.cant, this.mibarrio.cant, this.miotros.cant],
                // data: [1, 2, 3, 4, 5, 6],
                backgroundColor: [
                    'rgb(1, 106, 172, 0.7)',
                    'rgb(1, 106, 172, 0.7)',
                    'rgb(1, 106, 172, 0.7)',
                    'rgb(1, 106, 172, 0.7)',
                    'rgb(1, 106, 172, 0.7)',
                    'rgb(1, 106, 172, 0.7)'
                ]
            },],
        };

        const config = {
            type: 'polarArea',
            data: data,
            options: {
                plugins: {
                  legend: false,
                  tooltip: false,
                },
                layout: {
                    padding: 10
                }
            }
        };

        let ctx = this.template.querySelector('canvas.mainChart').getContext('2d');
        this.chart_main = new Chart(ctx, config);
    }

    healthChart() {

        const data = {
            labels: [this.misalud.programa, ''],
            datasets: [{
              label: '',
              data: [this.misalud.percent, 100-this.misalud.percent],
              backgroundColor: ['rgb(1, 106, 172)', 'rgb(237, 238, 240)'],
              hoverOffset: 4
            }]
        };

        let config = {
            type: 'doughnut',
            data: data,
            options: {
                responsive:true,
                plugins: {
                    legend: false,
                    tooltip: false,
                },
            cutoutPercentage:92,
            rotation: (0.5 * Math.PI)+(1/5 * Math.PI), 
            circumference: 2*0.8 * Math.PI
        }};

        let ctx = this.template.querySelector('canvas.healthChart').getContext('2d');
        this.chart_salud = new Chart(ctx, config);
    }

    contactsChart() {
        const data = {
            labels: [this.mibarrio.programa, ''],
            datasets: [{
              label: '',
              data: [this.mibarrio.percent, 100-this.mibarrio.percent],
              backgroundColor: ['rgb(1, 106, 172)', 'rgb(237, 238, 240)'],
              hoverOffset: 4
            }]
        };

        let config = {
            type: 'doughnut',
            data: data,
            options: {
                responsive:true,
                plugins: {
                    legend: false,
                    tooltip: false,
                },
            cutoutPercentage:92,
            rotation: (0.5 * Math.PI)+(1/5 * Math.PI), 
            circumference: 2*0.8 * Math.PI
        }};

        let ctx = this.template.querySelector('canvas.contactsChart').getContext('2d');
        this.chart_barrio = new Chart(ctx, config);
    }

    box3Chart() {
        const data = {
            labels: [this.milicencia.programa, ''],
            datasets: [{
              label: '',
              data: [this.milicencia.percent, 100-this.milicencia.percent],
              backgroundColor: ['rgb(1, 106, 172)', 'rgb(237, 238, 240)'],
              hoverOffset: 4
            }]
        };

        let config = {
            type: 'doughnut',
            data: data,
            options: {
                responsive:true,
                plugins: {
                    legend: false,
                    tooltip: false,
                },
            cutoutPercentage:92,
            rotation: (0.5 * Math.PI)+(1/5 * Math.PI), 
            circumference: 2*0.8 * Math.PI
        }};

        let ctx = this.template.querySelector('canvas.box3Chart').getContext('2d');
        this.chart_licencia = new Chart(ctx, config);
    }

    box4Chart() {
        const data = {
            labels: [this.mimascota.programa, ''],
            datasets: [{
              label: '',
              data: [this.mimascota.percent, 100-this.mimascota.percent],
              backgroundColor: ['rgb(1, 106, 172)', 'rgb(237, 238, 240)'],
              hoverOffset: 4
            }]
        };

        let config = {
            type: 'doughnut',
            data: data,
            options: {
                responsive:true,
                plugins: {
                    legend: false,
                    tooltip: false,
                },
            cutoutPercentage:92,
            rotation: (0.5 * Math.PI)+(1/5 * Math.PI), 
            circumference: 2*0.8 * Math.PI
        }};

        let ctx = this.template.querySelector('canvas.box4Chart').getContext('2d');
        this.chart_mascota = new Chart(ctx, config);
    }
    
    box5Chart() {
        const data = {
            labels: [this.miwifi.programa, ''],
            datasets: [{
              label: '',
              data: [this.miwifi.percent, 100-this.miwifi.percent],
              backgroundColor: ['rgb(1, 106, 172)', 'rgb(237, 238, 240)'],
              hoverOffset: 4
            }]
        };

        let config = {
            type: 'doughnut',
            data: data,
            options: {
                responsive:true,
                plugins: {
                    legend: false,
                    tooltip: false,
                },
            cutoutPercentage:92,
            rotation: (0.5 * Math.PI)+(1/5 * Math.PI), 
            circumference: 2*0.8 * Math.PI
        }};

        let ctx = this.template.querySelector('canvas.box5Chart').getContext('2d');
        this.chart_wifi = new Chart(ctx, config);
    }
    
    box6Chart() {
        const data = {
            labels: [this.miotros.programa, ''],
            datasets: [{
              label: '',
              data: [this.miotros.percent, 100-this.miotros.percent],
              backgroundColor: ['rgb(1, 106, 172)', 'rgb(237, 238, 240)'],
              hoverOffset: 4
            }]
        };

        let config = {
            type: 'doughnut',
            data: data,
            options: {
                responsive:true,
                plugins: {
                    legend: false,
                    tooltip: false,
                },
            cutoutPercentage:92,
            rotation: (0.5 * Math.PI)+(1/5 * Math.PI), 
            circumference: 2*0.8 * Math.PI
        }};

        let ctx = this.template.querySelector('canvas.box6Chart').getContext('2d');
        this.chart_otros = new Chart(ctx, config);
    }


}