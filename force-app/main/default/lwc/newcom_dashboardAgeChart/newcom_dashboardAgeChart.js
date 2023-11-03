import { LightningElement, api, track } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';

export default class Newcom_dashboardAgeChart extends LightningElement {
    // @api community;
    // @api terrw;

    @api total_women;
    @api total_women_perc;
    @api total_men;
    @api total_men_perc;
    @api labels_aux;
    @api women_count;
    @api men_count;

    @track peopleCount = [];

    isChartJsInitialized = false;

    connectedCallback() {
        for(let i=0; i<=5; i++)
            this.peopleCount[i] = this.women_count[i] + this.men_count[i];
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
            labels: ['Mujeres', 'Hombres'],
            datasets: [{
                // label: [],
                data: [this.total_women, this.total_men],
                backgroundColor: [
                    'rgb(136, 84, 147, 0.7)',
                    'rgb(0, 130, 190, 0.7)'
                ]
            },],
        };

        const config = {
            type: 'doughnut',
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

        let ctx = this.template.querySelector('canvas.peopleChart').getContext('2d');
        this.chart_people = new Chart(ctx, config);
    }

    ageChart() {
        const data = {
            // labels: ['0-17', '18-24', '25-39', '40-64', '+65'],
            labels: [this.labels_aux[0], this.labels_aux[1], this.labels_aux[2], this.labels_aux[3], this.labels_aux[4], this.labels_aux[5]],
            datasets: [{
                // label: [],
                data: [this.men_count[0], this.men_count[1], this.men_count[2], this.men_count[3], this.men_count[4], this.men_count[5]],
                backgroundColor: [
                    // 'rgb(136, 84, 147, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)',
                    'rgb(0, 130, 190, 0.7)'
                ]
            },],
        };

        const config = {
            type: 'bar',
            data: data,
            options: {
                // y: {
                //     beginAtZero: true
                // }
                // ,plugins: {
                //     legend: false,
                //     tooltip: false,
                // }
                // ,layout: {
                //     padding: 10
                // }
            }
        };

        let ctx = this.template.querySelector('canvas.ageChart').getContext('2d');
        this.chart_age = new Chart(ctx, config);
    }
}