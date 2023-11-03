import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_ActividadesTileList extends LightningElement {
        //dejo de andar la reactividad de las propiedades sin el track...
        @api set imageRouteParam (value){
            this._imageRouteParam = value;
            this.tileImage = Resources + this.imageRouteParam;
        }
        get imageRouteParam () {
            return this._imageRouteParam;
        }
        @track tileImage;
    
    
        @api set results(value) {
            if(!value || !value[0]) return
            this._results = value;
            let queryResults = value[0];

            let tempTileList = [];

            for(let thisLabel in queryResults){
                tempTileList.push({
                    label: thisLabel,
                    value: queryResults[thisLabel],
                    key: queryResults[thisLabel]
                });
            }

            const tempListSorted = tempTileList.sort((tileA, tileB) => tileB.value - tileA.value);

            const tempListAsString = tempListSorted.map(thisTile => {
                const stringValue = thisTile.value.toLocaleString();
                let temObj = {
                    value: stringValue,
                    label: thisTile.label,
                    key: thisTile.key
                }
                return temObj;
            })
            
            this.tileList = tempListAsString;

        }
        get results() {
            return this._results;
        }
        @track tileList;
    
        @api metadata;
        @api setSelection;
        @api selectMode;
    
        @api getState;
        @api setState;
    
        @api selection
    
        @api filterFieldParam;

        handleClickTile (event) {
            if(!this.filterFieldParam) return;

            let tempState = {...this.getState()};

            for (let thisConfigItem of tempState.state.datasets.TerritoryFullPage_DS){
                if(thisConfigItem.fields[0] === this.filterFieldParam){
                    thisConfigItem.filter.operator = 'matches';
                    thisConfigItem.filter.values = event.currentTarget.getAttribute('data-tilelable');
                }
            }
            this.setState(tempState);
        }
    
}