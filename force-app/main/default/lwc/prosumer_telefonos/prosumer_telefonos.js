import { LightningElement, api } from 'lwc';
import Resources from '@salesforce/resourceUrl/prosumerAudiencia';

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return { forceLog: () => console.log(...stringsToLog) };
    }
    console.log(...stringsToLog);
    return { forceLog: () => null };
}

export default class Prosumer_telefonos extends LightningElement {
    @api param_data_from_analytics;

    imgSource = Resources + '/telefono.png';
    imgAlt = 'Telefonos fijos';

    get value () {
        let totalsFromAnalytics = this.param_data_from_analytics?.Counting_All?.results[0] ?? {};
        const intValue = totalsFromAnalytics.Countable_TienePhone ?? 0 ;
        return intValue.toLocaleString('es-AR');
    }

    name = 'Teléfonos fijos';

    get cssClasses() {
        if (this.isSelected) {
            return 'box selected';
        }
        return 'box';
    }

    isSelected = false;

    handelClick() {
        this.fireTogleEvent();
        this.togleLocalFilter();
    }

    fireTogleEvent() {
        const labelForEvent = 'Tiene telefono fijo';
        const filterObjectForEvent = {
            filterArray: [{ filterField: 'HomePhone', filterComparisonValue: 'not null', filterComparisonOperator: 'is' }]
        };
        const bindedFunction = function tempFunction () { this.togleLocalFilter() }.bind(this);
        const filterClickEvent = new CustomEvent('filterclick', { detail: { filterObject: filterObjectForEvent, label: labelForEvent, bindedFunction } });
        this.dispatchEvent(filterClickEvent);
    }

    @api
    togleLocalFilter() {
        this.isSelected = !this.isSelected;
    }

    @api removeAllLocalFilters () {
        this.isSelected = false;
    }

}