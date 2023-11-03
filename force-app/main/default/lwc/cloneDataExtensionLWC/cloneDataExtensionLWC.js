import { LightningElement, track } from 'lwc';
import prmCloneDataExtensionRequestInit from '@salesforce/apex/prmCloneDataExtensionRequest.prmCloneDataExtensionRequestInit';

export default class CloneDataExtensionLWC extends LightningElement {
    @track DataExtensionFrom = '';
    @track DataExtensionTo = '';

    cloneHandler() {
        var clonerequest = {};

        if (this.DataExtensionFrom.length > 0 && this.DataExtensionTo.length > 0) {

            clonerequest.argDataExtensionFrom  = this.DataExtensionFrom;
            clonerequest.argDataExtensionTo    = this.DataExtensionTo;

            clonerequest.argFilterOneField     = '';
            clonerequest.argFilterOneCondition = '';
            clonerequest.argFilterOneValue     = '';

            clonerequest.argFilterTwoField     = '';
            clonerequest.argFilterTwoCondition = '';
            clonerequest.argFilterTwoValue     = '';

            clonerequest.argFilterCondition    = '';

            if (this.filterOneValue.length > 0) {
                clonerequest.argFilterOneField     = this.filterOneField;
                clonerequest.argFilterOneCondition = this.filterOneCondition;
                clonerequest.argFilterOneValue     = this.filterOneValue;
                
                if (this.filterTwoValue.length > 0) {
                    clonerequest.argFilterTwoField     = this.filterTwoField;
                    clonerequest.argFilterTwoCondition = this.filterTwoCondition;
                    clonerequest.argFilterTwoValue     = this.filterTwoValue;

                    clonerequest.argFilterCondition    = this.filterCondition;
                }
            }
            prmCloneDataExtensionRequestInit(clonerequest);
        }
    }

    cleanHandler() {
        this.DataExtensionFrom  = '';
        this.DataExtensionTo    = '';
        this.filterOneField     = '';
        this.filterOneCondition = 'equals';
        this.filterOneValue     = '';
        this.filterTwoField     = '';
        this.filterTwoCondition = 'equals';
        this.filterTwoValue     = '';
        this.filterCondition    = '';
    }

    deFromChangeHandler(event) {
        this.DataExtensionFrom = event.target.value;
    }

    deToChangeHandler(event) {
        this.DataExtensionTo = event.target.value;
    }


    @track filterOneField = '';
    @track filterTwoField = '';

    filterOneFieldChangeHandler(event) {
        this.filterOneField = event.detail.value;
    }

    filterTwoFieldChangeHandler(event) {
        this.filterTwoField = event.detail.value;
    }


    @track filterOneCondition = 'equals';
    @track filterTwoCondition = 'equals';

    get conditionOptions() {
        return [
            { label: 'Igual a', value: 'equals' },
            { label: 'Distinto de', value: 'noequals' },
            { label: 'Contiene', value: 'like' },
        ];
    }

    filterOneConditionChangeHandler(event) {
        this.filterOneCondition = event.detail.value;
    }

    filterTwoConditionChangeHandler(event) {
        this.filterTwoCondition = event.detail.value;
    }


    @track filterOneValue = '';
    @track filterTwoValue = '';

    filterOneValueChangeHandler(event) {
        this.filterOneValue = event.detail.value;
    }

    filterTwoValueChangeHandler(event) {
        this.filterTwoValue = event.detail.value;
    }


    @track filterCondition = '';

    get radioOptions() {
        return [
            { label: 'AND', value: 'AND' },
            { label: 'OR' , value: 'OR' },
        ];
    }

    radioChangeHandler(event) {
        this.filterCondition = event.detail.value;
    }


    //@track comboOptions;
    // @track comboValue;
    // get comboOptions() {
    //     //return this.loadDataExtensions();
    //      return [
    //          { label: 'zUno', value: 'zuno' },
    //          { label: 'zDos', value: 'zdos' },
    //          { label: 'zTres', value: 'ztres' },
    //      ];
    // }
    // handleChange(event) {
    //     this.value = event.detail.value;
    // }

    //@track comboOptions;
    //loadDataExtensions() {
        // var FLAG = true;

        // var labelList = [
        //     { label: 'xUno', value: 'xuno' },
        //     { label: 'xDos', value: 'xdos' },
        //     { label: 'xTres', value: 'xtres' },
        // ];

        // // eslint-disable-next-line vars-on-top
        // var xhr = new XMLHttpRequest();
        // const method = 'GET';
        // const url = 'https://100.24.241.185/retrieve_data_extensions';
    
        // if ("withCredentials" in xhr) {
        //     xhr.open(method, url, true);
        // } else {
        //     throw new Error('CORS not supported');        
        // }
    
        // xhr.setRequestHeader("Content-type", "application/json");
        // xhr.send("{'userid':'0056A00000308vtQAA'}");
    
        // xhr.onload = function() {
        //     if(this.status === 200) {
        //         const response = JSON.parse(this.responseText);
        //         const dataExtensions = String(response.message);
        //         var index = 0;
        //         while (index !== -1) {
        //             index = dataExtensions.indexOf("Name", index);
        //             if (index !== -1) {
        //                 var from = dataExtensions.indexOf("\"", index);
        //                 var to = dataExtensions.indexOf("\"", from + 1);
        //                 index = to + 1;
        //                 var deName = dataExtensions.substring(from + 1, to);
        //                 //console.log(deName);
        //             }
        //         }
        //         // eslint-disable-next-line vars-on-top
        //         labelList = [
        //             { label: 'Uno', value: 'uno' },
        //             { label: 'Dos', value: 'dos' },
        //             { label: 'Tres', value: 'tres' },
        //         ];
        //         this.comboOptions = labelList;
        //         component.set()
        //         FLAG = false;
        //         return labelList;
        //     }
        // };
    
        // xhr.onerror = function() {
        //     // eslint-disable-next-line no-alert
        //     alert(this.responseText);
        // };

        // while(FLAG == true) {};

        // return labelList;
    //}

}