({
    isLoadedScript : false,
    isLoadedInit : false,
    objChart: null,
    
    updateChart : function(objComponent) {
        objChart.update();
    },
    
    refreshChart : function(component, recordId) {
        var action = null;
        var state = null;
        var territoryWrapper = null;
        
        if(recordId !== undefined && recordId !== null && (recordId.length === 15 || recordId.length === 18)) {
            action = component.get("c.getTerritoryById");
            action.setParams({
                "territoryId": recordId
            });
            
            action.setCallback(this, function(response) {
                state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    territoryWrapper = response.getReturnValue();
                    var labels = territoryWrapper.labelsAux;
                    var menCount = territoryWrapper.menCount;
                    var womenCount = territoryWrapper.womenCount;
                    
                    var womenChartConfig = {
                        labels: labels,
                        datasets: [{
                            label: 'MUJERES',
                            data: womenCount,
                            backgroundColor: [
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e'
                            ],
                            borderColor: [
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e'
                            ],
                            borderWidth: 1
                        }]
                    };
                    
                    var menChartConfig = {
                        labels: labels,
                        datasets: [{
                            label: 'HOMBRES',
                            data: menCount,
                            backgroundColor: [
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e'
                            ],
                            borderColor: [
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e',
                                '#00a08e'
                            ],
                            borderWidth: 1
                        }]
                    };
                    
                    var womenDiv = document.getElementById('women').getContext('2d');
                    var menDiv = document.getElementById('men').getContext('2d');
                    
                    var womenChart = new Chart(womenDiv, { 
                        type : 'bar' ,
                        data : womenChartConfig, 
                        options: {
                            legend: {display: false},
                            scales: {
                                xAxes: [{
                                    gridLines: {
                                        display:false
                                    }
                                }],
                                yAxes: [{
                                    ticks: {
                                        display: false 
                                    }
                                }]
                            }
                        } 
                    });
                    
                    var menChart = new Chart(menDiv, { 
                        type : 'bar' ,
                        data : menChartConfig, 
                        options: {
                            legend: {display: false},
                            scales: {
                                xAxes: [{
                                    gridLines: {
                                        display:false
                                    }
                                }],
                                yAxes: [{
                                    ticks: {
                                        display: false 
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