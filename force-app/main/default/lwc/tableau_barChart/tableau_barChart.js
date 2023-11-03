import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJS';

//palette for non param colors
const PALETTE = [
    [255, 99, 132],
    [255, 159, 64],
    [255, 205, 86],
    [75, 192, 192],
    [54, 162, 235]
];

export default class Tableau_barChart extends LightningElement {
    //begin framework params ----
    @api set results(value) {
        //sin update, porque hasta ahora, cuando el dash inyecta un cambio, setea results y setea selection
        //con el update en set selections alcanza.
        this._results = value;
    }
    get results() {
        return this._results;
    }

    @api metadata;
    @api setSelection;
    @api selectMode;

    @api getState;
    @api setState;

    @api set selection(value) {
        this._selection = value;
        if (this.chart != null) {
            this.chart.data = this.makeData();
            this.chart.update();
        }
    }

    get selection() {
        return this._selection;
    }

    //end framework params ----

    //custom params
    //la variable a donde buscar el valor a mostrar en el objeto results
    @api measureColumnParam;
    //la variable a donde buscar etiquetas de eje x en el objeto resutls (categorias1)
    @api axisParam;
    //la variable a donde buscar agrupamiento en el objeto resutls (categoria2: grupos apilados)
    @api groupsParam;
    //orden de las categorias 1
    @api axisOrderParam;
    //colores para cada categoria de tipo2
    @api set colorsByGroupParam(value) {
        try {
            this._colorsByGroupParam = JSON.parse(value);
        } catch (e) {
            this._colorsByGroupParam = {};
        }
    }

    @api lensNameParam;

    get colorsByGroupParam() {
        return this._colorsByGroupParam;
    }

    renderedCallback() {
        console.log('dashboard state', JSON.stringify(this.getState()));

        if (this.chartjsInitialized) {
            return;
        }

        this.chartjsInitialized = true;

        loadScript(this, chartjs + '/Chart.bundle.min.js').then(
            () => {
                // disable Chart.js CSS injection ?? esto estaba en el ejemplo...
                window.Chart.platform.disableCSSInjection = true;

                const canvas = document.createElement('canvas');
                this.template.querySelector('div.chart').appendChild(canvas);

                const ctx = canvas.getContext('2d');
                this.chart = new window.Chart(ctx, this.makeConfig());

            }
        );
    }

    getLabelsInOrder() {
        try {
            return JSON.parse(this.axisOrderParam);
        } catch (e) {
            const labelsSet = new Set(this.results.map(thisResult => thisResult[this.axisParam]));
            return [...labelsSet]
        }
    }

    makeMultiLinesLabels () {
        let defaultLabels = this.getLabelsInOrder();
        return defaultLabels.map(thisLabel =>{
            return thisLabel.split(' ');
        });
    }

    makeConfig() {

        return {
            type: 'bar',
            data: this.makeData(),
            options: {
                y: {
                    beginAtZero: true
                },
                plugins: {
                    title: {
                        display: false
                    },
                    legend: false,
                    tooltip: false,
                },
                layout: {
                    padding: 10
                },
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        stacked: true,
                    },
                    y: {
                        stacked: true,
                    },
                    yAxes: [{
                        ticks: {
                            callback: function (label, index, labels) {
                                if (label > 1000000) {
                                    return label / 1000000 + ' millones';
                                } else if (label > 1000) {
                                    var miles = label / 1000 < 1000 ? ' miles' : ' millón';
                                    var cantidad = label / 1000 < 1000 ? label / 1000 : label / 1000000;
                                    return cantidad + miles;
                                } else {
                                    return label;
                                }
                            },
                            fontSize: 11
                        }
                    }],
                    xAxes: [{
                        ticks: {
                            autoSkip: false,
                            fontSize: 11
                        }
                    }]
                },
                onClick: (event, elements) => {
                    console.log('hola amiguinesss');
                    const clickedElement = this.chart.getElementsAtEventForMode(event, 'nearest', { intersect: true, axis: 'x' }, false);

                    if (clickedElement.length !== 0) {
                        //se clickeo una seleccion
                        const datasetLabel = clickedElement[0]._model.datasetLabel
                        const xAxisLabel = clickedElement[0]._model.label.join(' ');

                        let selectionArray = this.results.filter(thisResult => {
                            return thisResult[this.axisParam] === xAxisLabel && thisResult[this.groupsParam] === datasetLabel
                        });

                        this.setSelection(selectionArray);

                        return;
                    }

                    /*
                    const clickedOverTheXAxis = this.chart.scales['y-axis-0'].getValueForPixel(event.y) > 0;
                    console.log('barchar y-axis-value', this.chart.scales['y-axis-0'].getValueForPixel(event.y))
                    */

                    /* ESTO NO FUNCIONA BIEN.
                    if (clickedOverTheXAxis) {
                        //se clickio espacio vacio sobre el grafio. Seteo seleccion a vaci
                        console.log('barchar seleccion vacia');
                        this.setSelection([]);
                        return;
                    }
                    */

                    //se clickeo debajo del grafico. Aplico filtro global, y seteo seleccion a vacio []

                    const clickedColumn = this.chart.getElementsAtEventForMode(event, 'nearest', { intersect: false, axis: 'x' }, false);

                    let tempState = { ...this.getState() };
                    for (let thisConfigItem of tempState.state.datasets.TerritoryFullPage_DS) {
                        if (thisConfigItem.fields[0] === this.axisParam) {
                            thisConfigItem.filter.operator = 'matches';
                            thisConfigItem.filter.values = clickedColumn[0]._model.label.join(' ');
                        }
                    }
                    if (this.lensNameParam && tempState.state.steps[this.lensNameParam]) tempState.state.steps[this.lensNameParam].values = [];

                    this.setState(tempState);
                }
            }
        }
    }

    makeData() {
        let datasets;
        if (!this.groupsParam) {
            datasets = makeUngroupedDatasets.bind(this)();
        } else {
            datasets = makeGroupedDatasets.bind(this)();
        }

        //labels en varias lineas. Hardcodeado, seria una cosa asi
        //let labels = [[["SUB"],["16"]],["CENTENNIALS"],["MILENNIALS"],[["GENERACION"],["X"]],[["BABY"],["BOOMERS"]],[["GENERACION"],["SILENCIOSA"]]];

        const tempObj = {
            //labels,
            labels : this.makeMultiLinesLabels(),
            datasets
        }

        return tempObj

        function makeUngroupedDatasets() {
            console.log('makeUngroupedDatasets');
            return {};
        }

        function makeGroupedDatasets() {

            let tempGroupedDatasets = [];

            const groupsKeysSet = new Set(this.results.map(thisResult => thisResult[this.groupsParam]));

            let i = 0;
            groupsKeysSet.forEach(thisKey => {
                tempGroupedDatasets.push(
                    {
                        label: thisKey,
                        data: this.makeValuesArrayOrderedByLabels(thisKey),
                        backgroundColor: this.makeColorArray(thisKey, i),
                        stack: 'Stack 0',
                    }
                )
                i++;
            });

            return tempGroupedDatasets;
        }
    }

    makeValuesArrayOrderedByLabels(groupKey) {
        const labels = this.getLabelsInOrder();
        let valuesOrderedByLabels = [];

        labels.forEach(thisLabel => {
            let value = 0;
            this.results.forEach(thisResult => {
                if (thisResult[this.groupsParam] === groupKey && thisResult[this.axisParam] === thisLabel) {
                    value += thisResult[this.measureColumnParam];
                }
            })

            valuesOrderedByLabels.push(value);
        });

        return valuesOrderedByLabels;
    }
    makeColorArray(groupKey, index) {
        const labels = this.getLabelsInOrder();
        return labels.map(thisLabel => {
            let isFaded = false;
            if (this.selection.length !== 0) {
                let selectedColumn = this.selection[0][this.axisParam]
                let selectedGroupKey = this.selection[0][this.groupsParam]
                isFaded = (selectedGroupKey !== groupKey) || (selectedColumn !== thisLabel)
            }
            return this.makeColor(groupKey, index, isFaded);
        })

    }
    makeColor(groupKey, index, isFaded) {
        if (this.colorsByGroupParam.hasOwnProperty(groupKey)) {
            const paramColor = this.colorsByGroupParam[groupKey];
            return `rgba(${paramColor}, ${isFaded ? '0.2' : '1'})`
        }

        const [r, g, b] = PALETTE[index % PALETTE.length];

        return `rgba(${r}, ${g}, ${b}, ${isFaded ? '0.2' : '1'})`;
    }
}