import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';
import Resources2 from '@salesforce/resourceUrl/prosumerAudiencia';
import Prosumer from '@salesforce/resourceUrl/prosumerIconsActEc';

const IS_LOG_ENABLED = false;
const DEFAULT_LOG = 'Prosumer, economicas: ';

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


//esto esta maso, hay que verificar que siempre esten sincronizados con los valores que usa y que espera la query.
//pero bueno, a su vez, el requerimiento es que las actividades se tienen que mostrar aunque la query de 0 (en cuyo caso no la devuelve)
const ACTIVIDADES_ECONOMICAS_DEFAULT = {
    'Arte y recreación': 0,
    'Comercio': 0,
    'Comunicación e información': 0,
    'Construcción': 0,
    'Gestión de desechos': 0,
    'Educación': 0,
    'Extractivismo': 0,
    'Finanzas y aseguradoras': 0,
    'Gas y electricidad': 0,
    'Hotelería y gastronomía': 0,
    'Industrias manufactureras': 0,
    'Inmobiliarias': 0,
    'Justicia': 0,
    'Reparaciones y oficios': 0,
    'Empleo público': 0,
    'Reparaciones y suministro de servicios básicos': 0,
    'Rural': 0,
    'Salud': 0,
    'Fuerzas de seguridad': 0,
    'Servicios profesionales': 0,
    'Tecnología': 0,
    'Transporte': 0,
}

const ICONOS_PROFESIONES = {
    'Arte y recreación': Prosumer + '/arte-recreacion@2x.png',
    'Comercio': Prosumer + '/comercio@2x.png',
    'Comunicación e información': Prosumer + '/comunicacion@2x.png',
    'Construcción': Prosumer + '/construccion@2x.png',
    'Gestión de desechos': Prosumer + '/residuos@2x.png', 
    'Educación': Prosumer + '/educacion@2x.png',
    'Extractivismo': Prosumer + '/extractivismo@2x.png',
    'Finanzas y aseguradoras': Prosumer + '/finanzas@2x.png',
    'Hotelería y gastronomía': Prosumer + '/turismo-gastronomia@2x.png',
    'Industrias manufactureras': Prosumer + '/ind-manufactureras@2x.png',
    'Inmobiliarias': Prosumer + '/inmobiliario@2x.png',
    'Justicia': Prosumer + '/justicia@2x.png',
    'Reparaciones y oficios': Prosumer + '/reparaciones@2x.png',
    'Empleo público': Prosumer + '/empleo-publico@2x.png',
    'Reparaciones y suministro de servicios básicos': Prosumer + '/suministros@2x.png',
    'Rural': Prosumer + '/rural@2x.png',
    'Salud': Prosumer + '/saluud@2x.png',
    'Fuerzas de seguridad': Prosumer + '/fuerzas-seguridad@2x.png',
    'Servicios profesionales': Prosumer + '/servicios-profesionales@2x.png',
    'Transporte': Prosumer + '/transporrte@2x.png',

    // Resto de profesiones...
};

export default class Prosumer_economicas extends LightningElement {
    iconEmpleado = Resources + '/SALESFORCE/img/Territories/ae_empleado.svg';
    acteconomicas = Resources2 + '/acteconomicas.png';

    @api param_data_from_analytics;

    selectedLabels = [];

    get actividadesEconomicas() {
        let data = {
            ...ACTIVIDADES_ECONOMICAS_DEFAULT
        };

        let queryData = this.param_data_from_analytics.Counting_All?.results[0];

        if (queryData) {
            data = {
                ...queryData
            };
        }

        let tempArray = [];

        Object.entries(data).forEach(([key, value]) => {
            //como ahora la query vendria con varias cosas, hay que filtrar. Y hay que venir a ACTIVIDADES_ECONOMICAS_DEFAULT
            //a agregar cada una a mano.
            if(!Object.keys(ACTIVIDADES_ECONOMICAS_DEFAULT).includes(key)) return
            tempArray.push({
                "image": ICONOS_PROFESIONES[key] || this.iconEmpleado,
                "name": key,
                "value": value,
                "actividadfilter": key,
            })

        });


        let sortedArray = tempArray.sort((a, b) => { return b.value - a.value });

        sortedArray.forEach(thisElement => {
            thisElement.value = thisElement.value.toLocaleString('es-AR')
        })

        const tempArrayWithCss = sortedArray.map( thisItem => {
            if(this.selectedLabels.length === 0 || this.selectedLabels.includes(thisItem.actividadfilter)){
                return {
                    ...thisItem,
                    cssClasses: 'item'
                }
            }
            return {
                ...thisItem,
                cssClasses: 'item notSelected'
            }
        });

        return tempArrayWithCss;
    }

    handelClick_Actividades(event) {
        let label = event.currentTarget.dataset.actividadfilter;
        this.fireTogleEvent (label);
        this.togleLocalFilter (label);
    }

    fireTogleEvent(label){
        //{filterArray,isBaseFilter,filterLogicalOperator}
        let filterObject = {
            filterArray: [
                { filterField: 'actividades_economicas__c', filterComparisonOperator: 'matches', filterComparisonValue: label }
            ]
        }

        //funcion a modo de callback que el otro componente usa para remover filtros de forma directa

        //tempFunction hace de wrapper a la funcion local de togleLocalFilter y "guardando",
            //el valor de "label" de cuando el codigo paso por aca, tonces el callback,
            // cuando se ejecuta, utiliza el valor correcto

        //la parte de .bind()
            // la puse para asegurarme que togleLocalFilter siga teniendo acceso a este componente

        //finalmente el otro componente hace un bindedFunction(), cuando quiera sacar un label del array de filtros
        const bindedFunction = function tempFunction () { this.togleLocalFilter(label) }.bind(this);

        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject, label, bindedFunction } });
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