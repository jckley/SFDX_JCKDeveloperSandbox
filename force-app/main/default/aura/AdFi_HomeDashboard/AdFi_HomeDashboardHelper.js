({
    DEBUG : false,
    retrieveRootTerritory : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objTerritory = null;
        var objThat = this;
        
        this.DEBUG && console.log('[AdFi_HomeDashboard]retrieveRootTerritory ->');
        
        objControllerAction = objComponent.get("c.getRootTerritoryInfo"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                objTerritory = objResponse.getReturnValue();
                objComponent.set('v.territory', objTerritory);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
        this.DEBUG && console.log('[AdFi_HomeDashboard]retrieveRootTerritory <-');
    },
    
    retrieveChartData : function(component, recordId) {
        var action = null;
        var state = null;
        var territoryWrapper = null;
        console.log('Entra al helper pero no al if');
        console.log(recordId)
       
        if(recordId !== undefined && recordId !== null && (recordId.length === 15 || recordId.length === 18)) {
            console.log('Entra al helper y al if');
            action = component.get("c.getTerritoryById");
            action.setParams({
            	"territoryId": recordId
            });
            
            action.setCallback(this, function(response) {
                state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    territoryWrapper = response.getReturnValue();
                    var bar1color = component.get('v.bar1color');
                    var bar2color = component.get('v.bar2color');
                    var labels = territoryWrapper.labelsAux;
                    var menCount = territoryWrapper.menCount;
                    var womenCount = territoryWrapper.womenCount;
                    var menPerc = territoryWrapper.totalMenPerc;
                    var womenPerc = territoryWrapper.totalWomenPerc;
                    console.log(menPerc);
                    console.log(womenPerc);
                    //component.set('v.totalMen', territoryWrapper.totalMen);
                    //component.set('v.totalWomen', territoryWrapper.totalWomen);
                    
                    var objConfig = {
                labels: labels,
                datasets: [{
                    label: 'MUJERES',
                    data: womenCount,
                    backgroundColor: [
                        '#da2297',
                        '#da2297',
                        '#da2297',
                        '#da2297',
                        '#da2297',
                        '#da2297'
                    ],
                    borderColor: [
                        '#da2297',
                        '#da2297',
                        '#da2297',
                        '#da2297',
                        '#da2297',
                        '#da2297'
                    ],
                    borderWidth: 1
                },
                           {
                               label: 'HOMBRES',
                               data: menCount,
                               backgroundColor: [
                                   '#229fda',
                                   '#229fda',
                                   '#229fda',
                                   '#229fda',
                                   '#229fda',
                                   '#229fda'
                               ],
                               borderColor: [
                                   '#229fda',
                                   '#229fda',
                                   '#229fda',
                                   '#229fda',
                                   '#229fda',
                                   '#229fda'
                               ],
                               borderWidth: 1
                           }          ]
            };
            
            var objDiv = document.getElementById('canvas').getContext('2d');            
            var objChart = new Chart(
                objDiv, { 
                    type : 'bar' ,
                    data : objConfig,
                    options: {
                        legend: {display: false},
                        maintainAspectRatio : false,
                        scales: {
                            xAxes: [{
                                gridLines: {
                                    display:false
                                }
                            }],
                            yAxes: [{
                                gridLines: {
                                    display:false
                                }   
                            }]
                        }
                    }
                });
                } 
            });
            
            $A.enqueueAction(action); 
        }
    }
})