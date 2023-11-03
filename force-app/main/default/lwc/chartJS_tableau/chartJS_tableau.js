import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJS';

// R, G, B
const PALETTE = [
    [255, 99, 132],
    [255, 159, 64],
    [255, 205, 86],
    [75, 192, 192],
    [54, 162, 235]
];

//rgb mas: 0 130 190
//rgb fem: 136 84 147

export default class ChartJS_tableau extends LightningElement {
    //variables de lwc para tableau
    //results guarda en un array, los resultados de la query que alimenta al componente.
    //ej [{"Gender__c":"m","count":24463164},{"Gender__c":"f","count":234512312}]

    //entre selection y results hay una dinamica rara. Al hacer clic en otro componente. Si mete filtros, se setean results nuevos y se setea una selection nueva a "vacio"
    //en cambio al hacer clic en el propio componente, los results no se setean, pero la selection si. Por eso, poniendo el update en set selection () estamos seguro de que corre siempre
    //y no hace falta ponerlo aca tmb.
    @api set results(value) {
        this._results = value;
    };
    get results() {
        return this._results;
    };

    //no tiene mucho. Parece que guarda info como, segun que variable se agrupo la query
    //{"groups":["Gender__c"],"strings":["Gender__c"],"numbers":["count"]}
    @api metadata;

    //esto es una funcion que el entorno le pasa como callback al componente este.
    //al ejecutar la funcion, pasandole como parametro un array de filtros. El dashboard usa esa info filtrar los otros componentes (y tambien este mismo calculo).
    @api setSelection;

    //estos no se estan usand?
    @api selectMode;


    //get y set state estan asociados a estados del dashboar.

    //por ejemplo, esta info se ve al obtener el estado antes y despues de aplicar un filtro general en los steps:
    //dash status "default"
    /*{
            "pageId":"3b22dd3a-e949-4ba7-93b4-e7da1a1627d3",
            "state":{
                "datasets":{},
                "sObjects":{},
                "reports":{},
                "cdpObjects":{},
                "steps":{
                    "civil_status__c_1":{"values":[],"metadata":{"groups":["civil_status__c"]}},
                    "lens_1":{"values":[],"metadata":{"groups":["Genero"]}}
                }
            }
        }
    */

    //al aplicar un filtro, cambia la parte de steps:
    /*
        "steps":{
            "civil_status__c_1":{"values":["Casado"],"metadata":{"groups":["civil_status__c"]}},
            "lens_1":{"values":[],"metadata":{"groups":["Genero"]}}
        }
    */

    //no entiendo por que, no aparece el nuevo filtro en la lens_1 igual
    @api getState;
    @api setState;


    //selection guarda la info de la ultima seleccion realizada en este grafico.
    //basicamente, guardo la row, del array de data, donde se hizo clic
    //ojo aca, esto no lo setea el propio componente. Si no que cuando algun componente, que use este misma query, llama al callback de setSelection(row)
    //entonces el dash, setea el parametro selection, a lo que se le envio al callback (Ademas de correr las querys de las otras lens/otras querys.)
    @api
    get selection() {
        return this._selection;
    }

    set selection(selection) {
        this._selection = selection;
        if (this.chart != null) {
            /*
            //en el grafico de dona, los datos terminan en data.dataset[0].data
            //data[0] = m data[1] = f
            customLog('refreshPopulationChart, data in chart: ');
            this.chartPopulation.data.datasets[0].data[0] = this.analitycsGenderData.menSumary;
            this.chartPopulation.data.datasets[0].data[1] = this.analitycsGenderData.womenSumary;
            this.chartPopulation.update();
            */
            this.chart.data = this.makeChartData();
            this.chart.update();
        }
    }

    //variables custom, definidas en el xml
    @api measureColumn;
    @api labelColumn;
    @api removeNullFilters;

    @api set colorsByGroup(value) {
        try {
            this._colorsByGroup = JSON.parse(value);
        } catch (e) {
            this._colorsByGroup = {};
        }
    }

    get colorsByGroup() {
        return this._colorsByGroup;
    }

    chart;
    chartjsInitialized = false;

    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        loadScript(this, chartjs + '/Chart.bundle.min.js').then(
            () => {
                // disable Chart.js CSS injection ?? esto estaba en el ejemplo...
                window.Chart.platform.disableCSSInjection = true;

                //crean el canvas y lo insertan el div, no se cual sera la diferencia
                const canvas = document.createElement('canvas');
                //al ponerle esto, parece que empieza a ocupar todo el conteiner donde esta embebido
                canvas.style.height = '0px'
                canvas.style.width = '0px'
                this.template.querySelector('div.chart').appendChild(canvas);

                const ctx = canvas.getContext('2d');
                this.chart = new window.Chart(ctx, this.makeConfig());

            }
        );

        if (this.removeNullFilters) {

            let tempStateFiltersAndStaticLevels = setStaticAdminLevel(this.getState())

            if(tempStateFiltersAndStaticLevels) {
                this.setState(tempStateFiltersAndStaticLevels);
            }
        }

        function setStaticAdminLevel (state) {
            let tempState = { ...state };

            for (let thisFilter of tempState.state.datasets.TerritoryFullPage_DS) {
                //revisar filtros de nivel, para determinar el nivel del territorio
                const thisFilterFieldName = thisFilter.fields[0];

                if (thisFilterFieldName === 'fx_TerritoryTree') {
                    if(!thisFilter.filter.values[0]) return null;
                    const arrayTerritoryIds = thisFilter.filter.values[0].split('-');
                    const nextAdminLevel = (arrayTerritoryIds.length + 1).toString()
                    console.log('chartJS_tableau, trata de setear admin level static query to: ', nextAdminLevel);
                    tempState.state.steps.staticAdminLevels_1.values = [nextAdminLevel]
                    return tempState;
                }
            }

            return null;
        }

    }

    makeConfig() {

        return {
            type: 'doughnut',
            data: this.makeChartData(),
            options: {
                responsive: true,
                legend: false,
                animation: {
                    animateScale: true,
                    animateRotate: true
                },
                cutoutPercentage: 73,
                onClick: (event, elements) => {
                    //los elements, parecen tener una info muy parecida a los set de datos que alimentaron el grafico.
                    //como el orden se mantiene, this.results evaluado en thisElement._index. Equivale a obtener el objeto, con los resultados de la query
                    //que generaron la parte del grafico donde se hizo el click.

                    //por ejemplo, se le esta enviando a setSelection algo como [{"Gender__c":"m","count":24463164}]...
                    //es consistente con la docu, se envia una ROW de una query.
                    let selectionArray = elements.map((element) => this.results[element._index])

                    this.setSelection(selectionArray);
                },
                tooltips: {
                    enabled: false,
                    custom: this.makeTooltips()
                },
            }
        };
    }

    makeTooltips() {
        const chartjsTooltip = document.createElement('div');

        const tooltipDiv = document.createElement('div');
        const tooltipSelectedGroup = document.createElement('p');
        const tooltipSelectedValue = document.createElement('p');

        chartjsTooltip.classList.add('chartjsTooltip');

        tooltipDiv.appendChild(tooltipSelectedGroup);
        tooltipDiv.appendChild(tooltipSelectedValue);
        chartjsTooltip.appendChild(tooltipDiv);

        this.template.querySelector('div.chart').appendChild(chartjsTooltip);

        const customFunction = (tooltip) => {
            // Hide if no tooltip

            if (tooltip.opacity === 0) {
                tooltipSelectedGroup.innerText = 'none selected';
                tooltipSelectedValue.innerText = '';
                chartjsTooltip.style.display = 'none';
                return;
            }

            //el set de datos sobre el que se le hace hover esta aca en formato string:

            const stringData = tooltip.body[0].lines[0];
            const selectedKey = stringData.split(":")[0]
            const searchField = this.metadata.groups[0];
            const selectedRow = this.results.filter(result => result[searchField] === selectedKey)[0];
            const genderMap = selectedRow.Gender__c === 'f' ? 'Female' : 'Male';

            tooltipSelectedGroup.innerText = genderMap;
            tooltipSelectedValue.innerText = selectedRow.count;

            const color = this.getColorFromThisGroup(selectedRow.Gender__c)

            tooltipSelectedGroup.style.color = color;
            tooltipSelectedValue.style.color = color;
            chartjsTooltip.style.display = 'flex';
        }

        return customFunction;
    }

    getColorFromThisGroup(searchKey) {
        //la data y los colores estan guardados en el chart en el orden en el que vienen en results
        const searchField = this.metadata.groups[0];

        let resultIndex = this.results.findIndex(thisResult => thisResult[searchField] === searchKey)

        return this.chart.data.datasets[0].backgroundColor[resultIndex];
    }

    makeChartData() {
        const labels = this.results.map((row) => row[this.labelColumn])

        const selectedRowHashes = new Set(this.selection.map(selectionItem => this.hashRow(selectionItem)));

        let dataset = {
            data: this.results.map((row) => row[this.measureColumn]),
            backgroundColor: this.results.map((row, i) => {
                const thisRowHash = this.hashRow(row);
                return this.makeColor(thisRowHash, i, selectedRowHashes.size > 0 && !selectedRowHashes.has(thisRowHash))
            }
            ),
            label: 'Dataset 1'
        }

        let tempData = { datasets: [dataset], labels }


        //bindea para que this.hashRow

        return tempData;
    }

    hashRow(row) {
        //metadata.groups guarda las variables que se usaron para agrupar en la query como un array. Ej: "groups":["Gender__c"]
        //cada row evaluada en cada uno de los group daria una concatenacion de los indices de esa row para la query. Por ejemplo, si se agrupo por genero y edad
        //el array quedaria como ['f','Generacion x']
        let tempArray = this.metadata.groups.map((group) => {
            return row[group];
        })

        return tempArray.join('|^|');
    }

    makeColor(rowHash, index, isFaded) {
        //para un grafico con 1 sola variable, esto funciona, porque el hash de una row, va a ser valor que tomo la variable. Para el genero f o m y se puede pasar eso en el json
        //cuando haya mas de una variable. Hay que ver como hacer con el orden, o si armar otra estructura o algo asi
        //ej de config en builder: {"f":"136,84,147","m":"0,130,190"}
        if (this.colorsByGroup.hasOwnProperty(rowHash)) {
            const paramColor = this.colorsByGroup[rowHash];
            return `rgba(${paramColor}, ${isFaded ? '0.2' : '1'})`
        }

        const [r, g, b] = PALETTE[index % PALETTE.length];

        return `rgba(${r}, ${g}, ${b}, ${isFaded ? '0.2' : '1'})`;
    }
}