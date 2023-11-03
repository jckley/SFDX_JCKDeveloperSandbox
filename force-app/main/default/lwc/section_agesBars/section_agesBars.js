import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJS38';

import default_template from './default_template.html';
import evolution_template from './evolution_template.html';

const TEMPLATES_BY_NAME = {
    'evolution_template': evolution_template
}

const WOMEN_COLOR = '#885493';
const MEN_COLOR = '#0082be';

const PICK_LIST_TO_CHART_LABELS = {
    //el orden de las columnas va a venir dado por el orden del array de equivalencias.
    array: [
        { chartLabel: ['Sub', '16'], pickListValue: 'SUB 16' },
        { chartLabel: ['Centenials'], pickListValue: 'CENTENNIALS' },
        { chartLabel: ['Milenials'], pickListValue: 'MILENNIALS' },
        { chartLabel: ['Generación', 'X'], pickListValue: 'GENERACION X' },
        { chartLabel: ['Baby', 'Boomers'], pickListValue: 'BABY BOOMERS' },
        { chartLabel: ['Generación', 'Silenciosa'], pickListValue: 'GENERACION SILENCIOSA' },
    ],

    getLabels() {
        return this.array.map(thisEquivalencia => thisEquivalencia.chartLabel)
    },

    getPickListValues() {
        return this.array.map(thisEquivalencia => thisEquivalencia.pickListValue)
    }
}

const IS_LOG_ENABLED = true;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return { forceLog: () => console.log(...stringsToLog) };
    }
    console.log(...stringsToLog);
    return { forceLog: () => null };
}


export default class Section_agesBars extends LightningElement {
    @api
    set param_data_from_analytics(value) {
        customLog('dale lcoo', JSON.stringify(value) );
        this._param_data_from_analytics = value;
        refreshAgeChart(this.agesChart, this.analitycsAgesData);
    }

    get param_data_from_analytics() {
        return this._param_data_from_analytics;
    }

    @api param_template;

    render() {
        return this.param_template ? TEMPLATES_BY_NAME[this.param_template] : default_template;
    }

    _param_data_from_analytics;

    get analitycsAgesData() {

        //generos default
        let agesCount_byGender_byAgeRange = {
            m: {},
            f: {}
        };

        this.param_data_from_analytics.Ages.results.forEach(thisResult => {
            if (!agesCount_byGender_byAgeRange[thisResult.Genero]) {
                agesCount_byGender_byAgeRange[thisResult.Genero] = {};
            }
            agesCount_byGender_byAgeRange[thisResult.Genero][thisResult.Audiencia_Generaciones__c] = thisResult.count;
        })


        let pickListValues = PICK_LIST_TO_CHART_LABELS.getPickListValues();

        let tempObj = {
            m: [],
            f: []
        }

        pickListValues.forEach(thisValue => {
            //los generos default los pongo para que no rompa en esta parte
            let mTemp = agesCount_byGender_byAgeRange.m[thisValue] ? agesCount_byGender_byAgeRange.m[thisValue] : 0;
            let fTemp = agesCount_byGender_byAgeRange.f[thisValue] ? agesCount_byGender_byAgeRange.f[thisValue] : 0;
            tempObj.m.push(mTemp);
            tempObj.f.push(fTemp);
        })

        console.log('datos bs: ', tempObj)

        return tempObj;
    }


    agesChart;

    chartLibraryPromise;

    hitboxes;

    connectedCallback() {
        //cargo la libreria, la logica se hace en el render porque necesito tener el canvas en el html
        this.chartLibraryPromise = loadScript(this, chartjs + '/chart.min.js');
    }

    selectedTemplate = false;

    renderedCallback(){
        
        if (this.agesChart) return

        this.chartLibraryPromise
            .then(() => {
                const canvas = document.createElement('canvas');
                const charContainer = this.template.querySelector('div.chartContainer');
                const containerPadding = 30;
                canvas.height = charContainer.offsetHeight - containerPadding * 2;
                canvas.width = charContainer.offsetWidth - containerPadding * 2;
                this.template.querySelector('div.chartContainer').appendChild(canvas);
                const agesData = this.analitycsAgesData;
                this.agesChart = initAgesChart(agesData, canvas);
                Chart.register(this.makeEventPlugin(canvas));
                //Chart.register(this.makeLabelsBackgroundPlugin());
            })
            .catch((error) => {
                this.error = error;
                customLog('error al inicializar chartJs. AgesBar grafico', error).forceLog();
            });
    }

    makeEventPlugin(canvas) {
        const findLabel = (labels, evt) => {
            let found = false;
            let res = null;

            labels.forEach((label, index) => {
                if (evt.x > label.x && evt.x < label.x2 && evt.y > label.y && evt.y < label.y2) {
                    res = {
                        label: label.label,
                        index
                    };
                    found = true;
                }
            });

            return [found, res];
        };

        const commonGetLabelHitboxesBinded = this.commonGetLabelHitboxes.bind(this);

        const plugin = {
            id: 'customHover',
            afterEvent: (chart, event, opts) => {
                const evt = event.event;
                //aca seria mas rapido hacer el calculo de los hitbox una sola vez, al primer render, y luego, usarlo...
                //si se encuentra una forma de redibujar el grafico al cambiar el tamaño de la ventana, en ese momento habria que volver a disparar el calculo de los hitbox.

                const lbHitboxes = commonGetLabelHitboxesBinded(chart.scales);

                const [found, labelInfo] = findLabel(lbHitboxes, evt);

                if (found) {
                    canvas.style.cursor = 'pointer';

                    if (evt.type === 'click') {
                        console.log('etiqueta encontrada: ', labelInfo);
                        const generatedFiltersObject = createFilterFromLabel(labelInfo);
                        const filterLabel = labelInfo.label.join(' ');
                        this.fireFilterEvent(generatedFiltersObject, filterLabel);
                    }

                } else {
                    canvas.style.cursor = 'default';
                }
            }
        }
        return plugin;
    }
    /*
    makeLabelsBackgroundPlugin() {

        const commonGetLabelHitboxesBinded = this.commonGetLabelHitboxes.bind(this);

        return {
            id: 'labelsBackground',
            afterDraw(chart, args, options) {
                const ctx = chart.ctx;
                const labelsHitBoxes = commonGetLabelHitboxesBinded(chart.scales)
                labelsHitBoxes.forEach(thisHitbox => {
                    const statusPrevio = ctx.globalCompositeOperation;

                    ctx.globalCompositeOperation = 'destination-over';
                    ctx.fillStyle = 'rgba(252, 223, 220, 0.3)';

                    //geometria rectangulo, parece haber una distorcion en los ejes, y queda mejor usar paddings diferentes
                    const xPadding = 15;
                    const yPadding = 5;
                    const xInitPoint = thisHitbox.x - xPadding;
                    const yInitPoint = thisHitbox.y - yPadding;
                    const width = thisHitbox.x2 - thisHitbox.x + 2*xPadding;
                    const height = thisHitbox.y2 - thisHitbox.y + 2*yPadding;
                    ctx.fillRect(xInitPoint, yInitPoint, width, height);

                    //lo vuelvo al estado anterior, porque si no se queda "pegado"
                    ctx.globalCompositeOperation= statusPrevio;
                })
                

            }
        }
    }
    */
    labelHitboxes;

    commonGetLabelHitboxes(scales) {
        if (this.labelHitboxes) return this.labelHitboxes;

        const xScale = Object.values(scales).find(scale => scale.id === 'x');

        const tempHitboxes = xScale._labelItems.map((e, i) => {
            return {
                x: e.translation[0] - xScale._labelSizes.widths[i] / 2,
                x2: e.translation[0] + xScale._labelSizes.widths[i] / 2,
                y: e.translation[1],
                y2: e.translation[1] + xScale._labelSizes.heights[i],
                label: e.label,
                index: i
            }
        })

        this.labelHitboxes = tempHitboxes;
        return tempHitboxes;


    }


    fireFilterEvent(filterObject, label) {
        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject, label } });
        this.dispatchEvent(filterClickEvent);
    }

}


function initAgesChart(agesData, canvas) {
    customLog('Init ageChart');

    let labels = PICK_LIST_TO_CHART_LABELS.getLabels();

    let dataObject = agesData;

    let maleData = dataObject.m;
    let femaleData = dataObject.f;

    customLog('Get labels?');
    const dataResponse = {
        // These labels appear in the legend and in the tooltips when hovering different arcs
        labels,
        datasets: [
            {
                label: 'Hombres',
                data: maleData,
                backgroundColor: MEN_COLOR,
                stack: 'Stack 0',
            }, {
                label: 'Mujeres',
                data: femaleData,
                backgroundColor: WOMEN_COLOR,
                stack: 'Stack 0',
            }
        ]

    };

    const config = {
        type: 'bar',
        data: dataResponse,
        options: {
            // responsive: true permitiria que el grafico se ajuste a los cambios de tamaño del container. Pero rompe por la seguridad de salesforce y ni carga el grafico
            responsive: false,
            plugins: {
                legend: {
                    display: false
                },
            },
            animation: {
                animateScale: true,
                animateRotate: true
            },

            scales: {
                y: {
                    ticks: {
                        callback: transformarNumerosEnPalabras
                    }
                },
                //la caja de etiquetas tampoco queda linda la verdad. Hay que hacer algo fuera de las configuraciones standard para que sea potable.
                /*
                    x: {
                        ticks: { 
                            backdropPadding:2,
                            backdropColor:'#f7f6f2', 
                            showLabelBackdrop:true}
                      }
                */
            },
        },
    }

    let ctx = canvas.getContext('2d');

    return new Chart(ctx, config);
}

function refreshAgeChart(agesChart, agesData) {
    if (!agesChart) return;
    //en el grafico de barras, hay 2 datasets, y la info esta en chartAge.data.datasets[0].data
    //datasets[0] = m datasets[1] = f
    customLog('refreshAgeChart, data in chart: ');
    agesChart.data.datasets[0].data = agesData.m;
    agesChart.data.datasets[1].data = agesData.f;
    agesChart.update();
    customLog('finalizo refresh');
}


function createFilterFromLabel(labelInfo) {

    let audienciaFilter = PICK_LIST_TO_CHART_LABELS.array.filter(thisElement => {
        return (thisElement.chartLabel.flat().join('') === labelInfo.label.join(''))
    });

    audienciaFilter = audienciaFilter[0].pickListValue;

    let tempFilter = [];

    tempFilter.push({ filterField: 'Audiencia_Generaciones__c', filterComparisonValue: audienciaFilter, filterComparisonOperator: '==' });

    return {
        filterArray: tempFilter
    }
}

function transformarNumerosEnPalabras(label, index, labels) {
    if (label > 1000000) {
        return label / 1000000 + ' millones';
    }

    if (label > 1000) {
        const miles = label / 1000 < 1000 ? ' miles' : ' millón';
        const cantidad = label / 1000 < 1000 ? label / 1000 : label / 1000000;
        return cantidad + miles;
    }

    return label;
}