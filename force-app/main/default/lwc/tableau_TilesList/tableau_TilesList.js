import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_TilesList extends LightningElement {

    //workframe params
    @api set results(value) {
        this._results = value;
        const tempList = value.map(thisRow => {
            return {
                value: thisRow[this.valueColumnParam],
                label: thisRow[this.labelColumnParam],
                key: (thisRow[this.valueColumnParam] + thisRow[this.labelColumnParam])
            }
        }
        )

        const tempListSorted = tempList.sort((tileA, tileB) => tileB.value - tileA.value);

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
    @api metadata;
    @api setSelection;
    @api selectMode;

    @api getState;
    @api setState;
    @api selection;


    //custom params
    @api set imageRouteParam(value) {
        this._imageRouteParam = value;
        this.tileImage = Resources + this.imageRouteParam;
    }
    get imageRouteParam() {
        return this._imageRouteParam;
    }
    @track tileImage;

    @api valueColumnParam;
    @api labelColumnParam;


    @track tileList = [];

    handleClickTile(event) {
        const dashState = this.getState();

        const clickedElementLabel = event.currentTarget.getAttribute('data-tilelable');

        const levelByAdminLevelFilter = [
            { fieldApiName: 'Level1Name__c', adminLevelFilter: 2 },
            { fieldApiName: 'Level2Name__c', adminLevelFilter: 3 },
            { fieldApiName: 'Level3Name__c', adminLevelFilter: 4 },
            { fieldApiName: 'Level4Name__c' },
        ]

        let filterToUpdate;
        let adminLevelFilterToUpdate;

        for (let thisProperties of levelByAdminLevelFilter) {
            const filterToCheck = thisProperties.fieldApiName;

            const lastVoidFilter = dashState.state.datasets.TerritoryFullPage_DS.filter(thisFilter => {
                return (thisFilter.fields[0] === filterToCheck && thisFilter.filter.values.length === 0);
            })

            if (!filterToUpdate && lastVoidFilter.length !== 0) {
                filterToUpdate = lastVoidFilter[0];
                adminLevelFilterToUpdate = thisProperties.adminLevelFilter;
            }
        }

        if (filterToUpdate) {
            filterToUpdate.filter.values = [clickedElementLabel]

            let stateToSet = {
                state: {
                    datasets: {
                        TerritoryFullPage_DS: [filterToUpdate]
                    },
                    steps: {
                        staticAdminLevels_1: dashState.state.steps.staticAdminLevels_1
                    }
                }
            };

            if (adminLevelFilterToUpdate) {
                stateToSet.state.steps.staticAdminLevels_1.values = [adminLevelFilterToUpdate.toString()];
            }

            this.setState(stateToSet);
        }
    }

}