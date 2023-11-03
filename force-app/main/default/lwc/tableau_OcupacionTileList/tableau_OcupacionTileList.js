import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_OcupacionTileList extends LightningElement {

    @api set results(value) {
        try {
            console.log('OcupationTiles query: ', JSON.stringify(value))
            if (!value || !value[0]) return
            this._results = value;
            let queryResults = value[0];

            let tempTileList = [];

            for (let thisLabel in queryResults) {
                tempTileList.push({
                    label: thisLabel,
                    value: queryResults[thisLabel],
                    image: this.imagesByLabel[thisLabel]
                });
            }

            const tempListAsString = tempTileList.map(thisTile => {
                let temObj = {
                    value: thisTile.value.toLocaleString(),
                    label: thisTile.label,
                    image: thisTile.image
                }
                return temObj;
            })

            this.tileList = tempListAsString;
        } catch (error) {
            console.log('OcupationTiles error procesando la query: ', JSON.stringify(error))
        }
    }

    get results() {
        return this._results;
    }

    @api metadata;
    @api setSelection;
    @api selectMode;

    @api getState;
    @api setState;

    @api selection;

    @api filterFieldParam;

    imagesByLabel = {
        'Asalariado': Resources + '/SALESFORCE/img/Territories/icon_asalariado.svg',
        'Cuenta propia': Resources + '/SALESFORCE/img/Territories/icon_cuentaprop.svg',
        'Jubilados y pensionados': Resources + '/SALESFORCE/img/Territories/icon_jubilado.svg',
        'Sin ocupacion declarada': Resources + '/SALESFORCE/img/Territories/icon_siningresos.svg'
    }

    fieldToFilterByLabel = {
        'Asalariado': 'CI_Asalariado',
        'Cuenta propia': 'CI_Cuentapropista',
        'Jubilados y pensionados': 'CI_Jubilado',
        'Sin ocupacion declarada': 'CI_SinOcupacion'
    }

    @track tileList = [
        {
            value: 0,
            label: 'Asalariado',
            image: Resources + '/SALESFORCE/img/Territories/icon_asalariado.svg'
        },
        {
            value: 0,
            label: 'Cuenta propia',
            image: Resources + '/SALESFORCE/img/Territories/icon_cuentaprop.svg'
        },
        {
            value: 0,
            label: 'Jubilados y pensionados',
            image: Resources + '/SALESFORCE/img/Territories/icon_jubilado.svg'
        },
        {
            value: 0,
            label: 'Sin ocupacion declarada',
            image: Resources + '/SALESFORCE/img/Territories/icon_siningresos.svg'
        }
    ];

    handleClickTile(event) {
        let fieldToFilter = this.fieldToFilterByLabel[event.currentTarget.getAttribute('data-tilelable')]

        let tempState = { ...this.getState() };

        for (let thisConfigItem of tempState.state.datasets.TerritoryFullPage_DS) {
            //linda la sintaxis de los values eh
            if (thisConfigItem.fields[0] === fieldToFilter) {
                thisConfigItem.filter.operator = '==';
                thisConfigItem.filter.values = [[1]];
            }
        }
        this.setState(tempState);
    }
}