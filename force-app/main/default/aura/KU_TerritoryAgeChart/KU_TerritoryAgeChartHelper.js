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
            action = component.get("c.getTerritoryById2");
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
                    var totalMen = 0;
                    var totalWomen = 0;
                    menCount.forEach(function(item) {totalMen += item;});
                    womenCount.forEach(function(item) {totalWomen += item;});
                    
                    var womenChartConfig = {
                        labels: labels,
                        datasets: [{
                            label: 'MUJERES',
                            data: womenCount,
                            backgroundColor: [
                                '#de2f8e',
                                '#de2f8e',
                                '#de2f8e',
                                '#de2f8e',
                                '#de2f8e'
                            ],
                            borderColor: [
                                '#de2f8e',
                                '#de2f8e',
                                '#de2f8e',
                                '#de2f8e',
                                '#de2f8e'
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
                                '#00b4ff',
                                '#00b4ff',
                                '#00b4ff',
                                '#00b4ff',
                                '#00b4ff'
                            ],
                            borderColor: [
                                '#00b4ff',
                                '#00b4ff',
                                '#00b4ff',
                                '#00b4ff',
                                '#00b4ff'
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
                                    },
                                    ticks: {
                                        fontStyle: "bold",
                                        fontColor: "#333333",
                                    },
                                }],
                                yAxes: [{
                                    ticks: {
                                        display: false 
                                    }
                                }]
                            },
                            tooltips: {
                                callbacks: {
                                    label: function(tooltipItem, data) {
                                        var value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                        return ((value/totalWomen)*100).toFixed(2) + '%';
                                    }
                                } 
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
                                    },
                                    ticks: {
                                        fontStyle: "bold",
                                        fontColor: "#333333",
                                    },
                                }],
                                yAxes: [{
                                    ticks: {
                                        display: false 
                                    }
                                }]
                            },
                            tooltips: {
                                callbacks: {
                                    label: function(tooltipItem, data) {
                                        var value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                        return ((value/totalMen)*100).toFixed(2) + '%';
                                    }
                                } 
                            }
                        } 
                    });
                    
                } 
            });
            
            $A.enqueueAction(action); 
        }
    }
})