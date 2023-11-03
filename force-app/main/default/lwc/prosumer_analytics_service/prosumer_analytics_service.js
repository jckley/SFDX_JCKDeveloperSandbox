import { LightningElement, wire, api } from 'lwc';
import { executeQuery } from 'lightning/analyticsWaveApi';

/*
query example:

    let q = 'q = load "' + this.param_data_set + '/' + this.param_data_set_version + '";' +
          'q = filter q by \'Education_Level__c\' == "Terciario Completo" && \'Territorio_Administrativo__c.Id\' == "a2L6A000000EIO1UAO";'+
          'q = group q by Gender__c;'+
          'q = foreach q generate Gender__c as \'Genero\', count() as \'count\';'+
          'q = limit q 2000;';
 
*/


/*
ESTO ANDA, LA PREGUNTA ES SI ES MAS EFICIENTE QUE SUMAR COLUMNAS:
-- Load and filter the base dataset once
q_base = load "TerritoryFullPage_DS";


--Part 1: Subtotals for Audiencia_Generaciones__c and Gender__c
q_subtotals_gender = group q_base by ('Audiencia_Generaciones__c', 'Gender__c');
q_subtotals_gender = foreach q_subtotals_gender generate q_subtotals_gender.'Audiencia_Generaciones__c' as 'Audiencia_Generaciones__c', q_subtotals_gender.'Gender__c' as 'Gender__c', count(q_subtotals_gender) as 'Count';

// Part 2: Subtotals for Ingreso__c
q_ingreso = group q_base by 'Ingreso__c';
q_ingreso = foreach q_ingreso generate 'Ingreso__c' as 'Ingreso', count() as 'Count';

// Part 3: Subtotals for Audiencia_Generaciones__c
q_total = group q_base by 'Audiencia_Generaciones__c';
q_total = foreach q_total generate q_total.'Audiencia_Generaciones__c' as 'Audiencia_Generaciones__c', "Total" as 'Gender__c', count(q_total) as 'Count';

// Combining Subtotals for Gender and Total
q = union q_subtotals_gender, q_total, q_ingreso ;
q = order q by ('Audiencia_Generaciones__c' asc, 'Gender__c' asc);
q = limit q 2000;


*/

const AVAILABLES_QUERYS = {
    //estas querys no grupos, asi que existe la posibilidad de que se pueda obtener toda la info en 1 sola query
    BY_ALL:
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
            "sum('AE_Transporte') as 'Transporte'," +
            "sum('CI_Asalariado') as 'Asalariado'," +
            "sum('CI_SinOcupacion') as 'Sin ocupacion declarada'," +
            "sum('CI_Jubilado') as 'Jubilados y pensionados'," +
            "sum('CI_Cuentapropista') as 'Cuenta propia'," +
            "sum('ED_Analfabeto') as 'ED_Analfabeto'," +
            "sum('ED_Primario') as 'ED_Primario'," +
            "sum('ED_Secundario') as 'ED_Secundario'," +
            "sum('ED_Terciario') as 'ED_Terciario'," +
            "sum('ED_UniversitarioCompleto') as 'ED_UniversitarioCompleto'," +
            "sum('AG_SUB_16') as 'AG_SUB_16'," +
            "sum('AG_CENTENNIALS') as 'AG_CENTENNIALS'," +
            "sum('AG_MILENNIALS') as 'AG_MILENNIALS'," +
            "sum('AG_GENERACION_X') as 'AG_GENERACION_X'," +
            "sum('AG_BABY_BOOMERS') as 'AG_BABY_BOOMERS'," +
            "sum('AG_GENERACION_SILENCIOSA') as 'AG_GENERACION_SILENCIOSA'," +
            "sum('GENDER_F') as 'GENDER_F'," +
            "sum('GENDER_M') as 'GENDER_M'," +
            "sum('RI_MuyBajo') as 'RI_MuyBajo'," +
            "sum('RI_Bajo') as 'RI_Bajo'," +
            "sum('RI_Medio') as 'RI_Medio'," +
            "sum('RI_Alto') as 'RI_Alto'," +
            "sum('RI_MuyAlto') as 'RI_MuyAlto'," +
            "sum('Countable_TieneMobile') as 'Countable_TieneMobile'," +
            "sum('Countable_TieneEmail') as 'Countable_TieneEmail'," +
            "sum('Countable_TienePhone') as 'Countable_TienePhone'," +
            "unique('grouphash_coh__c') as 'grouphash_coh__c'," +
            "count(q) as 'Total';" +
        "q = limit q 2000;",
    //agrupados! pendiente desactivar: -------------------------------------------------------------------
    ADDRESS:
        "q = group q by all;" +
        "q = foreach q generate unique('grouphash_coh__c') as 'grouphash_coh__c';" +
        "q = limit q 2000;",
    HOME_PHONE:
        "q = filter q by HomePhone is not null;" +
        "q = group q by all;" +
        "q = foreach q generate count(q) as 'count';" +
        "q = limit q 2000;",
    MOBILE:
        "q = filter q by MobilePhone is not null;" +
        "q = group q by all;" +
        "q = foreach q generate count(q) as 'count';" +
        "q = limit q 2000;",
    EMAIL:
        "q = filter q by Email is not null;" +
        "q = group q by all;" +
        "q = foreach q generate count(q) as 'count';" +
        "q = limit q 2000;",
    BY_INGRESO:
        'q = group q by Ingreso__c;' +
        'q = foreach q generate Ingreso__c as \'Ingreso\', count() as \'count\';' +
        'q = limit q 2000;',
    BY_GENDER:
        'q = group q by Gender__c;' +
        'q = foreach q generate Gender__c as \'Genero\', count() as \'count\';' +
        'q = limit q 2000;', 
    BY_AGES:
        'q = group q by rollup(\'Audiencia_Generaciones__c\', \'Gender__c\');' +
        'q = foreach q generate Audiencia_Generaciones__c as \'Audiencia_Generaciones__c\', Gender__c as \'Genero\', count() as \'count\';' +
        'q = limit q 2000;',
    TOTAL:
        "q = group q by all;" +
        "q = foreach q generate count(q) as 'count';" +
        "q = limit q 2000;",
    BY_EDUCATION:
        'q = group q by Education_Level__c;' +
        'q = foreach q generate Education_Level__c as \'Education\', count() as \'count\';' +
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
    BY_OCUPACION:
        "q = group q by all;" +
        "q = foreach q generate " +
            "sum('CI_Asalariado') as 'Asalariado'," +
            "sum('CI_SinOcupacion') as 'Sin ocupacion declarada'," +
            "sum('CI_Jubilado') as 'Jubilados y pensionados'," +
            "sum('CI_Cuentapropista') as 'Cuenta propia';" +
        "q = limit q 2000;",
    //aca se pueden agregar nuevas, que basta que no esten en el manager
    //no se ejecutan y se pueden usar para pedir la "query"
    MC_MOBILE_PHONE:
    "q = filter q by MobilePhone is not null;" +
    "q = foreach q generate " +
            "guid__c as 'guid__c'," +
            "Id as 'Id'," +
            "MobilePhoneProsumerIVR as 'MobilePhoneProsumerIVR'," + 
            "MobilePhone as 'MobilePhone';" +
    "q = limit q 50;",
    MC_HOME_PHONE:
    "q = filter q by HomePhone is not null;" +
    "q = foreach q generate " +
            "guid__c as 'guid__c'," +
            "Id as 'Id'," + 
            "HomePhone as 'HomePhone';" +
    "q = limit q 50;",
    MC_EMAIL:
    "q = filter q by Email is not null;" +
    "q = foreach q generate " +
            "guid__c as 'guid__c'," +
            "Id as 'Id'," + 
            "Email as 'Email';" +
    "q = limit q 50;",
}
/*
    "q = foreach q generate " +
            "guid__c as 'guid__c'," +
            "Id as 'Id'," + 
            "MobilePhone as 'MobilePhone';" +
    "q = limit q 2000;",
*/
/*
    "q = group q by all;" +
    "q = foreach q generate count(q) as 'count';" +
    "q = limit q 2000;",
*/
const IS_LOG_ENABLED = true;
const DEFAULT_LOG = 'Prosumer AnalyticsService: ';

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

export default class Prosumer_analytics_service extends LightningElement {

    filters = [];
    
    //porque hay que terminar rapido para mostrar...
    @api param_base_string_filter;

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
        if(this.param_base_filters) {
            this.addBaseFilter(this.param_base_filters);
        }

        customLog('AnalyticsService, base string filter: ', this.param_base_string_filter);

        customLog('AnalyticsService, set filters ok');
    }

    get queryString() {
        customLog('AnalyticsService, queryString, getter');
        if (!this.param_data_set) { return undefined; }
        if (this.query_definition === 'BY_CHILD_TERRITORY' && !this.param_child_level_name) { return undefined; }
        customLog('AnalyticsService, trato de hacer query');

        let baseQuery = AVAILABLES_QUERYS[this.query_definition];

        if (this.query_definition === 'BY_CHILD_TERRITORY') {
            baseQuery =
                `q = group q by rollup(${this.param_child_level_name}, ${this.param_child_level_id});` +
                `q = foreach q generate ${this.param_child_level_name} as 'Name', ${this.param_child_level_id} as 'Id',${this.param_child_level_id} as '${this.param_child_level_id}', count() as 'count';` +
                'q = filter q by Id is not null;' +
                'q = limit q 2000;';
        }


        return this.makeBaseQuery(baseQuery)
    }

    makeBaseQuery(definedQuery) {
        //los api name de los campos y los valores son case sensitive!

        const stringBaseFilter = this.param_base_string_filter;
        let q =
            makeLoadArgument(this.param_data_set, this.param_data_set_version) +
            makeFiltersArgument(this.filters, stringBaseFilter) +
            definedQuery

        //el wire espera un objeto de la forma {query : {query: queryString}} ...
        customLog('AnalyticsService query final:', q);
        return { query: q }

        //prueba de encapsular las funciones que solamente serian usadas por esta funcion
        function makeLoadArgument(param_data_set, param_data_set_version) {
            return `q = load "${param_data_set}/${param_data_set_version}";`;
        }

        function makeFiltersArgument(allFilters, stringBaseFilter) {
            //aca habria que armar una clase aparte en algun lao y que el objeto de filtros salga de un constructor
            //ahi podria meter logica tmb para validar operadores soportados. Cosas como el "not" (anda pero era imposible saberlo sin usarlo)
            //y cosas asi

            //allFilters=[filterGroup1,filterGroup2,...,filterGroupN]
            //filterGroup={filterArray,isBaseFilter,filterLogicalOperator}
            //filterLogicalOperator: && o ||
            //filterArray:[filter1,filter2,...,filterN]
            //filter: {filterField:xxx,filterComparisonOperator:yyy,filterComparisonValue:zzz}            

            if (allFilters.length === 0 && !stringBaseFilter) return '';

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

            if (stringBaseFilter) {
                filterGroupsToJoinWithAnd.push(stringBaseFilter);
            }

            let filtersToReturn = 'q = filter q by ' + filterGroupsToJoinWithAnd.join('&&');

            filtersToReturn = filtersToReturn + ';';

            customLog('filtersString <--- ENTRA AL WAVE:', filtersToReturn);

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

    @api replaceFilterArray(oldFiltersArray, newFiltersArray) {
        //si coincide alguno de oldFiltersArray lo saca. Ademas, agrega todo lo que venga en newFiltersArray
        
        const oldFiltersArrayStrings = oldFiltersArray.map(thisFilterObject => JSON.stringify(thisFilterObject));
        
        const newFiltersToSetWithoutMatches = this.filters.filter( thisFilter => !oldFiltersArrayStrings.includes(JSON.stringify(thisFilter)));

        newFiltersToSetWithoutMatches.push(...newFiltersArray);

        this.filters = newFiltersToSetWithoutMatches;
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

    @api
    getSaqlStatementForMC () {
        return {
            mobilePhoneQuery_forMc: this.makeBaseQuery(AVAILABLES_QUERYS.MC_MOBILE_PHONE),
            homePhoneQuery_forMc: this.makeBaseQuery(AVAILABLES_QUERYS.MC_HOME_PHONE),
            emailQuery_forMc: this.makeBaseQuery(AVAILABLES_QUERYS.MC_EMAIL)
        }
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