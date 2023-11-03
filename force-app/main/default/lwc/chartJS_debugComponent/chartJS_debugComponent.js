import { LightningElement, api, track } from 'lwc';

export default class ChartJS_debugComponent extends LightningElement {   
    @api set results(value) {
        console.log('debugComponent setResults:', JSON.stringify(value));
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

    @api
    get selection() {
        return this._selection;
    }

    set selection(selection) {
        console.log('debugComponent selection variable: ', JSON.stringify(selection));
        this._selection = selection;
    }

    @api measureColumn;
    @api labelColumn;

    handleClick_getState (e) {
        console.log('debugComponent getState', JSON.stringify(this.getState()));
    }

    handleClick_setState (e) {
        console.log('debugComponent setState');
    }

    handleClick_setSelection (e) {
        console.log('debugComponent setSelection');
    }

    handleClick_getResults (e) {
        console.log('debugComponent getResults', this.results);
    }

}