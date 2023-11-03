import { LightningElement, wire, api } from 'lwc';
import { executeQuery, getDataset } from 'lightning/analyticsWaveApi';

/*
query example:

    let q = 'q = load "' + this.param_data_set + '/' + this.param_data_set_version + '";' +
          'q = filter q by \'Education_Level__c\' == "Terciario Completo" && \'Territorio_Administrativo__c.Id\' == "a2L6A000000EIO1UAO";'+
          'q = group q by Gender__c;'+
          'q = foreach q generate Gender__c as \'Genero\', count() as \'count\';'+
          'q = limit q 2000;';
 
*/

const AVAILABLES_QUERYS = {
    BY_AGES:
        'q = group q by rollup(\'Audiencia_Generaciones__c\', \'Gender__c\');' +
        'q = foreach q generate Audiencia_Generaciones__c as \'Audiencia_Generaciones__c\', Gender__c as \'Genero\', count() as \'count\';' +
        'q = limit q 2000;',

    BY_ACTIVIDAD_ECONOMICA:
        "q = group q by all;" +
        "q = foreach q generate " +
            "sum('AE_Arte') as 'Arte y recreación'," +
            "sum('AE_Comercio') as 'Comercio'," +
            "sum('AE_Comunicacion') as 'Comunicación e información'," +
            "sum('AE_Construccion') as 'Construcción'," +
            "sum('AE_Desechos') as 'Gestión de desechos'," +
            "sum('AE_Educacion') as 'Educación'," +
            "sum('AE_Extractivismo') as 'Extractivismo'," +
            "sum('AE_Finanzas') as 'Finanzas y aseguradoras'," +
            "sum('AE_Gas') as 'Gas y electricidad'," +
            "sum('AE_Hoteleria') as 'Hotelería y gastronomía'," +
            "sum('AE_Industrias') as 'Industrias manufactureras'," +
            "sum('AE_Inmobiliarias') as 'Inmobiliarias'," +
            "sum('AE_Justicia') as 'Justicia'," +
            "sum('AE_Oficios') as 'Reparaciones y oficios'," +
            "sum('AE_Publico') as 'Empleo público'," +
            "sum('AE_Reparaciones') as 'Reparaciones y suministro de servicios básicos'," +
            "sum('AE_Rural') as 'Rural'," +
            "sum('AE_Salud') as 'Salud'," +
            "sum('AE_Seguridad') as 'Fuerzas de seguridad'," +
            "sum('AE_Servicios') as 'Servicios profesionales'," +
            "sum('AE_Tecnologia') as 'Tecnología'," +
            "sum('AE_Transporte') as 'Transporte';" +
        "q = limit q 2000;",

    BY_GENDER:
        'q = group q by Gender__c;' +
        'q = foreach q generate Gender__c as \'Genero\', count() as \'count\';' +
        'q = limit q 2000;',

    BY_INGRESO:
        'q = group q by Ingreso__c;' +
        'q = foreach q generate Ingreso__c as \'Ingreso\', count() as \'count\';' +
        'q = limit q 2000;',
    BY_OCUPACION:
        "q = group q by all;" +
        "q = foreach q generate " +
        "sum('CI_Asalariado') as 'Asalariado'," +
        "sum('CI_SinOcupacion') as 'Sin ocupacion declarada'," +
        "sum('CI_Jubilado') as 'Jubilados y pensionados'," +
        "sum('CI_Cuentapropista') as 'Cuenta propia';" +
        "q = limit q 2000;",
    BY_EDUCATION:
        'q = group q by Education_Level__c;' +
        'q = foreach q generate Education_Level__c as \'Education\', count() as \'count\';' +
        'q = limit q 2000;',
}

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) return;
    console.log(...stringsToLog);
}

export default class AnalyticsService extends LightningElement {

    filters = [];
    @api param_data_set;
    @api param_data_set_version;
    @api query_definition;
    @api query_key;

    @api param_base_filters;

    @api param_child_level_name;
    @api param_child_level_id;

    connectedCallback() {
        customLog('Inciando AnalyticsService, key:', this.query_key);
        customLog('AnalyticsService, set filters by parameter', JSON.stringify(this.param_base_filters));
        this.addBaseFilter(this.param_base_filters);
        customLog('AnalyticsService, set filters ok');
    }

    get queryString() {
        customLog('AnalyticsService, queryString, getter');
        if (!this.param_data_set || this.filters.length === 0) { return undefined; }
        if (this.query_definition === 'BY_CHILD_TERRITORY' && !this.param_child_level_name) { return undefined; }
        customLog('AnalyticsService, trato de hacer query');

        let baseQuery = AVAILABLES_QUERYS[this.query_definition];

        if (this.query_definition === 'BY_CHILD_TERRITORY') {
            baseQuery =
                `q = group q by rollup(${this.param_child_level_name}, ${this.param_child_level_id});` +
                `q = foreach q generate ${this.param_child_level_name} as 'Name', ${this.param_child_level_id} as 'Id', count() as 'count';` +
                'q = filter q by Id is not null;' +
                'q = limit q 2000;';
        }


        return this.makeBaseQuery(baseQuery)
    }

    makeBaseQuery(definedQuery) {
        //los api name de los campos y los valores son case sensitive!
        let q =
            makeLoadArgument(this.param_data_set, this.param_data_set_version) +
            makeFiltersArgument(this.filters) +
            definedQuery

        //el wire espera un objeto de la forma {query : {query: queryString}} ...
        customLog('AnalyticsService query final:', q);
        return { query: q }


        //prueba de encapsular las funciones que solamente serian usadas por esta funcion
        function makeLoadArgument(param_data_set, param_data_set_version) {
            return `q = load "${param_data_set}/${param_data_set_version}";`;
        }

        function makeFiltersArgument(allFilters) {
            //allFilters=[filterGroup1,filterGroup2,...,filterGroupN]
            //filterGroup={filterArray,isBaseFilter,filterLogicalOperator}
            //filterLogicalOperator: && o ||
            //filterArray:[filter1,filter2,...,filterN]
            //filter: {filterField:xxx,filterComparisonOperator:yyy,filterComparisonValue:zzz}            

            if (allFilters.length === 0) return '';

            //el join entre filterGroups es siempre con and. Si no, no se termina mas esto.
            customLog('allFIlters:', JSON.stringify(allFilters));
            let filterGroupsToJoinWithAnd = allFilters.map(thisFilterGroup => {
                customLog('thisFilterGroup:', JSON.stringify(thisFilterGroup));

                let tempArrayForThisFilterGroup = thisFilterGroup.filterArray.map(thisFilter => {
                    if (thisFilter.filterComparisonOperator === '==' || thisFilter.filterComparisonOperator === 'matches') {
                        return `'${thisFilter.filterField}' ${thisFilter.filterComparisonOperator} "${thisFilter.filterComparisonValue}"`;
                    }
                    //sin comillas dobles para otro tipo de filtros, por ejemplo el in
                    return `'${thisFilter.filterField}' ${thisFilter.filterComparisonOperator} ${thisFilter.filterComparisonValue}`;
                });

                let thisGroupString = tempArrayForThisFilterGroup.join(thisFilterGroup.filterLogicalOperator);

                if (tempArrayForThisFilterGroup.length === 1) {
                    //si hay uno solo, el join no va a meter operador. Y la string no necesita los parentesis
                    return thisGroupString;
                }

                return `(${thisGroupString})`
            })

            let filtersToReturn = 'q = filter q by ' + filterGroupsToJoinWithAnd.join('&&');

            filtersToReturn = filtersToReturn + ';';

            customLog('filtersString:', filtersToReturn);

            return filtersToReturn;
        }
    }

    @api addTemporaryFilter(newFilters) {
        const newFiltersArray = [...this.filters];
        newFiltersArray.push(newFilters);

        this.filters = newFiltersArray;
    }

    @api toggleTemporaryFilter(newFilters) {
        //uso la conversion a string para comparar los objetos.
        customLog('toggleTemporaryFilter:', JSON.stringify(newFilters));
        const stringFilter = JSON.stringify(newFilters);

        const newFiltersArray_matchesFiltered = this.filters.filter( thisFilter => JSON.stringify(thisFilter) !== stringFilter );
        customLog('toggleTemporaryFilter luego de generar new array');
        
        const shouldAddFilter = newFiltersArray_matchesFiltered.length === this.filters.length;

        if (shouldAddFilter) {
            customLog('toggleTemporaryFilter agregar filtro');
            const newFiltersArray = [...this.filters];
            newFiltersArray.push(newFilters);
            this.filters = newFiltersArray;
        } else {
            customLog('toggleTemporaryFilter remover filtro');
            this.filters = newFiltersArray_matchesFiltered;
        }
        
    }

    @api addBaseFilter(newFilters) {
        customLog('addBaseFilter:', JSON.stringify(newFilters));

        let tempFilters = { ...newFilters };
        tempFilters.isBaseFilter = true;

        const newFiltersArray = [...this.filters];
        newFiltersArray.push(tempFilters)

        this.filters = newFiltersArray;
    }

    @api clearAllFilters() {
        this.filters = [];
    }

    @api clearTemporaryFilters() {
        //creo que a veces rompia array.filter() al usarlo de la variable directamente
        customLog('analitycsService, clear filters');
        let temp = [...this.filters];
        this.filters = temp.filter(thisFilter => Boolean(thisFilter.isBaseFilter));
        customLog('analitycsService, clear filters end ---> Deberia reacer la query');
    }

    @wire(executeQuery, { query: '$queryString' })
    onExecuteQuery_byGender({ data, error }) {
        customLog('WIRE QUERY');
        if (error) {
            customLog('analyticsService query ERROR:', JSON.stringify(error));
            let tempObject = {
                errorMsj: JSON.stringify(error),
                key: this.query_key
            };
            const queryErrorEvent = new CustomEvent('queryerror', { detail: tempObject });
            this.dispatchEvent(queryErrorEvent);
        } else if (data) {
            let tempObject = {
                results: data.results.records,
                key: this.query_key
            };
            const queryDataEvent = new CustomEvent('querydata', { detail: tempObject });
            this.dispatchEvent(queryDataEvent);
            customLog('WIRE QUERY, event dispatched');
        }
    }

}