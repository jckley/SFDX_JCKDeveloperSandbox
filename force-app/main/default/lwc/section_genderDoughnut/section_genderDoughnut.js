import { LightningElement, api } from 'lwc';

import { loadScript } from 'lightning/platformResourceLoader';

// ChartJS
import chartjs from '@salesforce/resourceUrl/ChartJS';

const WOMEN_COLOR = '#885493';
const MEN_COLOR = '#0082be';

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}

export default class Section_genderDoughnut extends LightningElement {

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
        return processAnalyticsData (this.param_data_from_analytics.Gender.results) ;
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
        this.chartLibraryPromise = loadScript(this, chartjs + '/Chart.bundle.min.js');
    }

    renderedCallback() {
        customLog("renderedCallback, ages doughnut").forceLog();
        if (this.populationChart) return
        this.chartLibraryPromise.then(()=>{
            if(window.Chart.platform) window.Chart.platform.disableCSSInjection = true;
            this.chartjsLoaded = true;
            const canvas = this.template.querySelector('canvas.populationChart')
            const tooltipsContainer = this.template.querySelector('div.chart-wrapper');
            const genderData = this.analitycsGenderData;
            this.populationChart = initPopulationChart(genderData, tooltipsContainer ,canvas);
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

    handelClick_PopulationChart(e) {
        var activePoints = this.populationChart.getElementsAtEvent(e);
        customLog('click on canvas: ')
        customLog('click on canvas: ', activePoints)
        // active points esta devolviendo un array. Para el grafico circular, siempre de length == 1.
        // el unico elemento es un objeto y contiene una propiedad "_index". Esa propiedad es el index del array que se uso para ese segmento de circulo.
        if (activePoints.length === 0) {
            return;
        }
        let tempFilterForGender = [];
        let label;
        let bindedFunction;
        if (activePoints[0]._index === 0) {
            //hombres
            tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'm', filterComparisonOperator: '==' })
            label = 'Hombres';
            this.togleLocalFilter('m');
            bindedFunction = function tempFunction () { this.togleLocalFilter('m') }.bind(this);
            customLog('filter m')
        }

        if (activePoints[0]._index === 1) {
            //mujeres
            tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'f', filterComparisonOperator: '==' })
            label = 'Mujeres';
            this.togleLocalFilter('f');
            bindedFunction = function tempFunction () { this.togleLocalFilter('f') }.bind(this);
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

function initPopulationChart(genderData, tooltipsContainer ,canvas) {
    customLog('Se inicia populationChart');

    const data = init_makeData (genderData);
    const tooltipsCallback = init_makeTooltips(tooltipsContainer);


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
                enabled: false,
                custom: tooltipsCallback
            },
            hover: {
                onHover: function(e) {
                   var point = this.getElementAtEvent(e);
                   if (point.length) e.target.style.cursor = 'pointer';
                   else e.target.style.cursor = 'default';
                }
            }
        }
    }

    let ctx = canvas.getContext('2d');
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
            borderColor: '#ffffff',
            borderWidth: 4,
            hoverBackgroundColor: [
                MEN_COLOR,
                WOMEN_COLOR,
            ],
            hoverBorderColor: '#ffffff',
            hoverBorderWidth: 0
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

    const customFunction = (tooltip) => {
        customLog('hover callback')
        // Hide if no tooltip
        
        if (tooltip.opacity === 0) {
            
            tooltipSelectedGroup.innerText = 'none selected';
            tooltipSelectedValue.innerText = '';
            chartjsTooltip.style.display = 'none';
            
            return;
        }

        customLog('hover callback, info disponible: ', tooltip).forceLog()
        
        //el set de datos sobre el que se le hace hover esta aca en formato string:
        const stringData = tooltip.body[0].lines[0];
        const selectedKey = stringData.split(":")[0];
        const selectedValue = stringData.split(":")[1];
        customLog('hover on grafico: ', selectedKey)

        tooltipSelectedGroup.innerText = selectedKey;
        //si podemos evitar usar el porcentaje, queda mas lindo, si no, hay pasar los datos porcentuales via parametro. Al menos siempre que siga intentando sacar "this." de las funciones
        //tooltipSelectedValue.innerText = selectedKey === 'Mujeres' ? `${genderData.womenPercent}%` : `${genderData.menPercent}%`;

        tooltipSelectedValue.innerText = parseInt(selectedValue, 10).toLocaleString('es-AR');

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
    customLog('make tooltips finish')
    return customFunction;
}

function processAnalyticsData (data) {
    let womenSumary = 0;
        let menSumary = 0;
        let otherSumary = 0;
        let totalSumary = 0;
        let womenPercent = 0;
        let menPercent = 0;
        let othermenPercent = 0;

        data.forEach(thisData => {
            if (thisData.Genero === 'f') {
                womenSumary = thisData.count;
            } else if (thisData.Genero === 'm') {
                menSumary = thisData.count;
            } else {
                otherSumary += thisData.count;
            }
            totalSumary += thisData.count;
        })

        womenPercent = womenSumary / totalSumary * 100;
        menPercent = menSumary / totalSumary * 100;
        othermenPercent = otherSumary / totalSumary * 100;

        womenPercent = parseFloat(womenPercent).toFixed(2);
        menPercent = parseFloat(menPercent).toFixed(2);
        othermenPercent = parseFloat(othermenPercent).toFixed(2);

        let menSumaryFormated = menSumary.toLocaleString('es-AR');
        let womenSumaryFormated = womenSumary.toLocaleString('es-AR');
        let totalSumaryFormated = totalSumary.toLocaleString('es-AR');

        let tempObject = {
            womenSumary,
            menSumary,
            otherSumary,
            totalSumary,
            womenPercent,
            menPercent,
            othermenPercent,
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
    customLog('refreshPopulationChart, data in chart: ');
    populationChart.data.datasets[0].data[0] = genderData.menSumary;
    populationChart.data.datasets[0].data[1] = genderData.womenSumary;
    populationChart.update();
    customLog('finalizo refresh');
}