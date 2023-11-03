import { LightningElement, track, wire,api } from 'lwc';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import getRootTerritory from '@salesforce/apex/CommunitiesController.getRootTerritory';
import RESOURCES from '@salesforce/resourceUrl/Communities';

import chartjs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';

export default class Newcom_dashboard extends LightningElement {
    @api countryName = null;
    @track communitySite;
    @track territoryWrapper;

    @track totalCiudadanosFormated = 0;
    @track totalemailsFormated = 0;
    @track totalMobilesFormated = 0;
    @track totalLandingFormated = 0;

    @track totalFacebookFormated = 0;
    @track totalInstagramFormated = 0;
    @track totalTwitterFormated = 0;
    @track totalLinkedinFormated = 0;
    @track facebookIcon;
    @track instagramIcon;
    @track twitterIcon;
    @track linkedinIcon;

    @track totalWomen = 0;
    @track totalWomenFormated = 0;
    @track totalWomenPerc = 0;
    @track womenCount = [];
    @track totalMen = 0;
    @track totalMenFormated = 0;
    @track totalMenPerc = 0;
    @track menCount = [];
    @track labelsAux = [];
    @track peopleCount = [];

    isChartJsInitialized = false;

    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            console.log('SITE:');
            console.log(data);
            this.communitySite = data;

            this.facebookIcon = RESOURCES + '/' + this.communitySite + '/img/facebook-b3b3b3.svg';;
            this.instagramIcon = RESOURCES + '/' + this.communitySite + '/img/instagram-b3b3b3.svg';
            this.twitterIcon = RESOURCES + '/' + this.communitySite + '/img/twitter-b3b3b3.svg';
            this.linkedinIcon = RESOURCES + '/' + this.communitySite + '/img/linkedin-b3b3b3.svg';

            this.error = undefined;
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.communitySite = undefined;
        }
    }

    @wire(getRootTerritory,{territoryName:'$countryName'})
    wiredTerritory({ error, data }) {
        if (data) {
            console.log('TERRITORY:');
            console.log(data);
            this.territoryWrapper = data;
            console.log('Territory Wrapper: ');
            console.log(this.territoryWrapper);

            this.totalCiudadanosFormated = this.territoryWrapper.totalCiudadanosFormated;
            this.totalemailsFormated = this.territoryWrapper.totalemailsFormated;
            this.totalMobilesFormated = this.territoryWrapper.totalMobilesFormated;
            this.totalLandingFormated = this.territoryWrapper.totalLandingFormated;

            this.totalFacebookFormated = this.territoryWrapper.totalFacebookFormated;
            this.totalInstagramFormated = this.territoryWrapper.totalInstagramFormated;
            this.totalTwitterFormated = this.territoryWrapper.totalTwitterFormated;
            this.totalLinkedinFormated = this.territoryWrapper.totalLinkedinFormated;

            this.totalWomen = this.territoryWrapper.totalWomen;
            this.totalWomenFormated = this.territoryWrapper.totalWomenFormated;
            this.totalWomenPerc = this.territoryWrapper.totalWomenPerc;
            this.womenCount = this.territoryWrapper.womenCount;

            this.totalMen = this.territoryWrapper.totalMen;
            this.totalMenFormated = this.territoryWrapper.totalMenFormated;
            this.totalMenPerc = this.territoryWrapper.totalMenPerc;
            this.menCount = this.territoryWrapper.menCount;

            this.labelsAux = this.territoryWrapper.labelsAux;

            for(let i=0; i<=5; i++)
                this.peopleCount[i] = this.womenCount[i] + this.menCount[i];
            console.log(this.peopleCount);

            this.peopleChart();
            this.ageChart();

            this.error = undefined;
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.territoryWrapper = undefined;
        }
    }

    connectedCallback() {
        console.log('newcom_dashboard In connectedCallback()...');



        // this.territoryWrapper = new TerritoryWrapper();
    }

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }

        // load chartjs from the static resource
        loadScript(this, chartjs + '/Chart.bundle.min.js')
            .then(() => {
                this.isChartJsInitialized = true;
                console.log('Dibujo charts');
                this.peopleChart();
                this.ageChart();
            })
            .catch(error => console.log(error));
    }

    peopleChart() {
        const data = {
            labels: ['Hombres', 'Mujeres'],
            datasets: [{
                // label: [],
                data: [this.totalMen, this.totalWomen],
                backgroundColor: [
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(136, 84, 147, 0.7)'
                ]
            },],
        };

        const config = {
            type: 'doughnut',
            data: data,
            options: {
                legend: {
                    display: false
                },
                cutoutPercentage: 73,
                circumference: 2 * Math.PI,
                maintainAspectRatio: false,
                animation: {
                    animateRotate: false,
                    animateScale: true
                },
                tooltips: {
                    enabled: false
                }
            }
        };

        let ctx = this.template.querySelector('canvas.peopleChart');
        this.chart_people = new Chart(ctx, config);
    }

    ageChart() {
        const actualYear = new Date().getFullYear();
        console.log('actual year:', actualYear);
        const data = {
            // labels: ['0-17', '18-24', '25-39', '40-64', '+65'],
            labels: ['0-'.concat((String)(actualYear-2004)),
                    ((String)(actualYear-2003)).concat('-',((String)(actualYear-1995))), 
                    ((String)(actualYear-1994)).concat('-',((String)(actualYear-1980))),
                    ((String)(actualYear-1979)).concat('-',((String)(actualYear-1965))),
                    ((String)(actualYear-1964)).concat('-',((String)(actualYear-1949))),
                    '+'.concat((String)(actualYear-1948))],
            // labels: [this.labelsAux[0], this.labelsAux[1], this.labelsAux[2], this.labelsAux[3], this.labelsAux[4], this.labelsAux[5]],
            datasets: [{
                label: 'Hombres',
                data: [this.menCount[0], this.menCount[1], this.menCount[2], this.menCount[3], this.menCount[4], this.menCount[5]],
                backgroundColor: [
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)'
                ],
                stack: 'Stack 0',
            },{
                label: 'Mujeres',
                data: [this.womenCount[0], this.womenCount[1], this.womenCount[2], this.womenCount[3], this.womenCount[4], this.womenCount[5]],
                backgroundColor: [
                    'rgb(136, 84, 147, 0.7)',
                    'rgb(136, 84, 147, 0.7)',
                    'rgb(136, 84, 147, 0.7)',
                    'rgb(136, 84, 147, 0.7)',
                    'rgb(136, 84, 147, 0.7)',
                    'rgb(136, 84, 147, 0.7)'
                ],
                stack: 'Stack 0',
            },],
        };

        const config = {
            type: 'bar',
            data: data,
            options: {
                y: {
                    beginAtZero: true
                }
                ,plugins: {
                    title: {
                        display: false
                    },
                    legend: false,
                    tooltip: false,
                }
                ,layout: {
                    padding: 10
                },
                responsive: true,
                scales: {
                    x: {
                        stacked: true,
                    },
                    y: {
                        stacked: true,
                    },
                    yAxes: [{
                        ticks: {
                            callback: function(label, index, labels) {
                                if(label>1000000){
                                    return label/1000000+' millones';
                                }else if(label>1000){
                                    var miles = label/1000 < 1000 ? ' miles' : ' millón';
                                    var cantidad = label/1000 < 1000 ? label/1000 : label/1000000;
                                    return cantidad+miles;
                                }else{
                                    return label;
                                }
                            }
                        }    
                    }]
                }
            }
        };

        let ctx = this.template.querySelector('canvas.ageChart').getContext('2d');
        this.chart_age = new Chart(ctx, config);
    }

}