import { LightningElement, api } from 'lwc';

import { loadScript } from 'lightning/platformResourceLoader';

// ChartJS
import chartjs from '@salesforce/resourceUrl/ChartJS38';

const WOMEN_COLOR = '#fd787d';
const MEN_COLOR = '#b10f0f';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, gender: ';

function customLog(...stringsToLog) {
    const strArray = [DEFAULT_LOG];
    const completeLog = strArray.concat(stringsToLog);

    //cuando los logs estan activos por default, logeo y retorno null  
    if (IS_LOG_ENABLED) {
        console.log(...completeLog);
        return {forceLog:()=>null};
    }
    //cuando no, necesito una funcion para permitir loggear a manopla en algunos lugares    
    return {forceLog:()=>console.log(...completeLog)};
}

export default class Prosumer_gender extends LightningElement {

    @api 
    set param_data_from_analytics (value) {
        this._param_data_from_analytics = value;
        refreshPopulationChart(this.populationChart, this.analitycsGenderData);
    }

    get param_data_from_analytics () {
        return this._param_data_from_analytics;
    }

    _param_data_from_analytics;


    populationChart;

    chartLibraryPromise;

    get analitycsGenderData() {
        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {}; 
        return processAnalyticsData (totalsFromAnalytics) ;
    }
    
    selectedLabels = [];

    get menCssClasses () {
        if (this.selectedLabels.length === 0 || this.selectedLabels.includes('m')) return 'stat'
        return 'stat notSelected'
    }

    get womenCssClasses () {
        if (this.selectedLabels.length === 0 || this.selectedLabels.includes('f')) return 'stat'
        return 'stat notSelected'
    }

    connectedCallback(){
        //cargo la libreria, la logica se hace en el render porque necesito tener el canvas en el html
        this.chartLibraryPromise = loadScript(this, chartjs + '/chart.min.js');
    }

    renderedCallback() {
        customLog("renderedCallback")

        if (this.populationChart) return
        customLog("renderedCallback, build populationChart")

        this.chartLibraryPromise
            .then(() => {
                const canvas = document.createElement('canvas');
                const charContainer = this.template.querySelector('div.chartContainer');
                const containerPadding = 30;
                canvas.height = charContainer.offsetHeight - containerPadding * 2;
                canvas.width = charContainer.offsetWidth - containerPadding * 2;
                this.template.querySelector('div.chartContainer').appendChild(canvas);
                const genderData = this.analitycsGenderData;
                const tooltipsContainer = this.template.querySelector('div.chartContainer');
                //ta fierucho, le cabe rework cuando haya tiempo
                //pasa que estamos en una urgencia de cambiar de chart v2 a v3 para este compoente
                const bindedFunction = this.handelClick_PopulationChart.bind(this)
                const populationChart = initPopulationChart(genderData, tooltipsContainer, canvas,  bindedFunction);
                this.populationChart = populationChart;
                customLog('Se completa populationChart');
            })

    }


    handleClickOnWomanStats () {
        customLog('filter f')
        const tempFilterForGender = [];
        tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'f', filterComparisonOperator: '==' })
        const bindedFunction = function tempFunction () { this.togleLocalFilter('f') }.bind(this);
        this.fireFilterEvent({ filterArray: tempFilterForGender }, 'Mujeres', bindedFunction);
        this.togleLocalFilter('f');
    }

    handleClickOnMenStats () {
        customLog('filter m')
        const tempFilterForGender = [];
        tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'm', filterComparisonOperator: '==' })
        const bindedFunction = function tempFunction () { this.togleLocalFilter('m') }.bind(this);
        this.fireFilterEvent({ filterArray: tempFilterForGender }, 'Hombres', bindedFunction);
        this.togleLocalFilter('m');
    }

    handelClick_PopulationChart(index) {
        let tempFilterForGender = [];
        let label;
        let bindedFunction;
        if (index === 0) {
            //hombres
            tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'm', filterComparisonOperator: '==' })
            label = 'Hombres';
            this.togleLocalFilter('m');
            bindedFunction = function tempFunction() { this.togleLocalFilter('m') }.bind(this);
            customLog('filter m')
        }

        if (index === 1) {
            //mujeres
            tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'f', filterComparisonOperator: '==' })
            label = 'Mujeres';
            this.togleLocalFilter('f');
            bindedFunction = function tempFunction() { this.togleLocalFilter('f') }.bind(this);
            customLog('filter f')
        }

        this.fireFilterEvent({ filterArray: tempFilterForGender }, label, bindedFunction);
    }

    fireFilterEvent (filterObject, label, bindedFunction) {
        const filterClickEvent = new CustomEvent('filterclick', { detail: {filterObject, label, bindedFunction} });
        this.dispatchEvent(filterClickEvent);
    }

    togleLocalFilter(clickedLabel) {
        if(!this.selectedLabels.includes(clickedLabel)){
            this.selectedLabels = [...this.selectedLabels, clickedLabel]
            return;
        }

        this.selectedLabels = this.selectedLabels.filter(thisItem => thisItem !== clickedLabel);
    }

    @api removeAllLocalFilters () {
        this.selectedLabels = [];
    }

}

function initPopulationChart(genderData, tooltipsContainer, canvas, handelClick_PopulationChart) {
    customLog('Se inicia populationChart');

    const data = init_makeData(genderData);
    const tooltipsCallback = init_makeTooltips(tooltipsContainer);


    const config = {
        type: 'doughnut',
        data: data,
        options: {
            responsive: false,
            circumference: 360,
            cutout: '55%',
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    // Disable the on-canvas tooltip
                    enabled: false,
                    external: tooltipsCallback
                }
            },
            onClick: (e, activeEls) => {
                customLog('CLICK!!!! Active Elements' , activeEls);
                let dataIndex = activeEls[0].index;
                handelClick_PopulationChart(dataIndex);
            }
        }
    }
    customLog('Previo a obtener canvas');
    let ctx = canvas.getContext('2d');
    customLog('Luego de obtener canvas: ', ctx);
    return new Chart(ctx, config);
}

function init_makeData (genderData) {
    const dataResponse = {
        // These labels appear in the legend and in the tooltips when hovering different arcs
        labels: [
            'Hombres',
            'Mujeres'
        ],
        datasets: [{
            data: [genderData.menSumary, genderData.womenSumary],
            backgroundColor: [
                MEN_COLOR,
                WOMEN_COLOR,
            ],
            borderColor: '#f1f3f3',
            borderWidth: 6,
            hoverBackgroundColor: [
                MEN_COLOR,
                WOMEN_COLOR,
            ],
            hoverBorderColor: '#e4e4e4',
            hoverBorderWidth: 6
        }]
    };
    return dataResponse;
}

function init_makeTooltips(tooltipsContainer) {
    customLog('make tooltips init');
    const chartjsTooltip = document.createElement('div');

    const tooltipSelectedGroup = document.createElement('p');
    const tooltipSelectedValue = document.createElement('p');

    chartjsTooltip.classList.add('chartjsTooltip');

    chartjsTooltip.appendChild(tooltipSelectedGroup);
    chartjsTooltip.appendChild(tooltipSelectedValue);

    tooltipsContainer.appendChild(chartjsTooltip);

    const customFunction = (context) => {
        customLog('hover callback')
        // Hide if no tooltip
        if (context.tooltip.opacity === 0) {
            tooltipSelectedGroup.innerText = 'none selected';
            tooltipSelectedValue.innerText = '';
            chartjsTooltip.style.display = 'none';
            return;
        }

        //el set de datos sobre el que se le hace hover esta aca en formato string:
        const stringData = context.tooltip.body[0].lines[0];
        const selectedKey = stringData.split(":")[0];
        const selectedValue = stringData.split(":")[1];

        tooltipSelectedGroup.innerText = selectedKey;
        //si podemos evitar usar el porcentaje, queda mas lindo, si no, hay pasar los datos porcentuales via parametro. Al menos siempre que siga intentando sacar "this." de las funciones
        //tooltipSelectedValue.innerText = selectedKey === 'Mujeres' ? `${genderData.womenPercent}%` : `${genderData.menPercent}%`;

        customLog('selectedValue ' , selectedValue)
        tooltipSelectedValue.innerText = selectedValue;

        const color = selectedKey === 'Mujeres' ? WOMEN_COLOR : MEN_COLOR;

        tooltipSelectedGroup.style.color = color;
        tooltipSelectedValue.style.color = color;
        tooltipSelectedValue.style.fontWeight = 'bold';
        tooltipSelectedValue.style.textAlign = 'center';
        chartjsTooltip.style.display = 'flex';
        chartjsTooltip.style.flexDirection = 'column';
        chartjsTooltip.style.position = 'absolute';
        chartjsTooltip.style.justifyContent = 'center';
        chartjsTooltip.style.alignItems = 'center';
        chartjsTooltip.style.zIndex = '0';
    }
    return customFunction;
}

function processAnalyticsData (totalsFromAnalytics) {
        let womenSumary = totalsFromAnalytics['GENDER_F'] ?? 0;
        let menSumary = totalsFromAnalytics['GENDER_M'] ?? 0;
        let totalSumary = womenSumary + menSumary;
        let womenPercent = 0;
        let menPercent = 0;

        if (totalSumary === 0) {
            return {
                womenSumary : 0,
                menSumary : 0,
                totalSumary : 0,
                womenPercent : '-',
                menPercent : '-',
                womenSumaryFormated : 0,
                menSumaryFormated : 0,
                totalSumaryFormated  : 0
            }
        }

        womenPercent =  womenSumary / totalSumary * 100;
        menPercent = menSumary / totalSumary * 100;

        womenPercent = parseFloat(womenPercent).toFixed(2) + '%';
        menPercent = parseFloat(menPercent).toFixed(2) + '%';

        let menSumaryFormated = menSumary.toLocaleString('es-AR');
        let womenSumaryFormated = womenSumary.toLocaleString('es-AR');
        let totalSumaryFormated = totalSumary.toLocaleString('es-AR');

        let tempObject = {
            womenSumary,
            menSumary,
            totalSumary,
            womenPercent,
            menPercent,
            womenSumaryFormated,
            menSumaryFormated,
            totalSumaryFormated
        }

        return tempObject;
}


function refreshPopulationChart(populationChart, genderData) {
    if (!populationChart) return;
    //en el grafico de dona, los datos terminan en data.dataset[0].data
    //data[0] = m data[1] = f
    populationChart.data.labels = ['Hombres', 'Mujeres'];
    populationChart.data.datasets[0].data[0] = genderData.menSumary;
    populationChart.data.datasets[0].data[1] = genderData.womenSumary;
    populationChart.update();
    customLog('finalizo refresh');
}