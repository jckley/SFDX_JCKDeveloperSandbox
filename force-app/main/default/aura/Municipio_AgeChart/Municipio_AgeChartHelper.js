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
                    var bar1color = component.get('v.bar1color');
                    var bar2color = component.get('v.bar2color');
                    var labels = territoryWrapper.labelsAux;
                    var menCount = territoryWrapper.menCount;
                    var womenCount = territoryWrapper.womenCount;
                    var menPerc = territoryWrapper.totalMenPerc;
                    var womenPerc = territoryWrapper.totalWomenPerc;
                    //component.set('v.totalMen', territoryWrapper.totalMen);
                    //component.set('v.totalWomen', territoryWrapper.totalWomen);
                    
                    var objConfig = {
                        labels: labels,
                        datasets: [{
                            label: 'MUJERES',
                            data: womenCount,
                            backgroundColor: [
                                bar1color,
                                bar1color,
                                bar1color,
                                bar1color,
                                bar1color,
                                bar1color
                            ],
                            borderColor: [
                                bar1color,
                                bar1color,
                                bar1color,
                                bar1color,
                                bar1color,
                                bar1color
                            ],
                            borderWidth: 1
                        },
						{
                            label: 'HOMBRES',
                            data: menCount,
                            backgroundColor: [
                                bar2color,
                                bar2color,
                                bar2color,
                                bar2color,
                                bar2color,
                                bar2color
                            ],
                            borderColor: [
                                bar2color,
                                bar2color,
                                bar2color,
                                bar2color,
                                bar2color,
                                bar2color
                            ],
                            borderWidth: 1
                        }]
                    };
                    var data1 = {
                        datasets: [{
                            data: [100-womenPerc, womenPerc],
                            backgroundColor: ['#edeef0', bar1color]
                        }],
                        
                        // These labels appear in the legend and in the tooltips when hovering different arcs
                        labels: ['','Mujeres %' ]
                    };
                    
                    var data2 = {
                        datasets: [{
                            data: [100-menPerc, menPerc],
                            backgroundColor: ['#edeef0', bar2color]
                        }],
                        
                        // These labels appear in the legend and in the tooltips when hovering different arcs
                        labels: ['','Hombres %' ]
                    };
                    
                    var ctx = document.getElementById('donnut').getContext('2d');
                    var myDoughnutChart = new Chart(ctx, {
                        type: 'doughnut',
                        data: data1,
                        options: {
                            legend: {display: false},
                            maintainAspectRatio : false,
                            cutoutPercentage: 90,
                            events: []
                        }
                    });
                    
                    var ctx2 = document.getElementById('donnut2').getContext('2d');
                    var myDoughnutChart = new Chart(ctx2, {
                        type: 'doughnut',
                        data: data2,
                        options: {
                            legend: {display: false},
                            maintainAspectRatio : false,
                            cutoutPercentage: 90,
                            events: []
                        }
                    });
                    
                    var objDiv = document.getElementById('canvas').getContext('2d');            
                    var objChart = new Chart(objDiv, { 
                        type : 'bar' ,
                        data : objConfig, 
                        options: {
                            legend: {display: false},
                            scales: {
                                xAxes: [{
                                    gridLines: {
                                        display:false
                                    }
                                }],
                                yAxes: [{
                                    gridLines: {
                                        display:false
                                    },
                                    ticks: {
                                        beginAtZero: true,
                                        callback: function(value, index, values) {
                                            if(parseInt(value) >= 1000){
                                                return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                                            } else {
                                                return value;
                                            }
                                        }
                                    }
                                }]
                            },
                            tooltips: {
                                callbacks: {
                                    label: function(tooltipItem, data) {
                                        var value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                        if(parseInt(value) >= 1000){
                                            return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                                        } else {
                                            return value;
                                        }
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