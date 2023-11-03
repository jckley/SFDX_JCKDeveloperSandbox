public class AdFi_ChartController {
	@AuraEnabled
    public static String retrieveChartDataExample(Integer intCategoryCount, Integer intDatasetCount) {
        RemotingMessageHelper.ChartData objChartData = null;
        RemotingMessageHelper.ChartDataset objChartDataset = null;
        String strJSON = null;
        
        System.debug('retrieveChartDataExample [intCategoryCount : ' + intCategoryCount + ' - intDatasetCount : ' + intDatasetCount + ' ] ->');
        
        try {       
            intCategoryCount = Integer.valueOf(intCategoryCount);
            intDatasetCount = Integer.valueOf(intDatasetCount);
            
            objChartData = new RemotingMessageHelper.ChartData();

            System.debug('retrieveChartDataExample [chart data created ] ');
            
            for(Integer intIndex = 0; intIndex < intCategoryCount; intIndex++) {
                objChartData.labels.add(String.format('Category {0}', new String[] { String.valueOf(intIndex) } ));
            }
            
            System.debug('retrieveChartDataExample [labels lodaed ] ');
            
            for(Integer intDatasetIndex = 0; intDatasetIndex < intDatasetCount; intDatasetIndex++) {
                objChartDataset = new RemotingMessageHelper.ChartDataset();
                objChartDataset.label = String.format('Dataset {0}',  new String[] { String.valueOf(intDatasetIndex) });
                for(Integer intCategoryIndex = 0;intCategoryIndex < intCategoryCount; intCategoryIndex++) {
                    objChartDataset.data.add( generateRandomNumber(100));                
                }     
                
                objChartData.datasets.add(objChartDataset);
            }                
            
            objChartData.options.title.text = 'Esto es una prueba!';
            objChartData.options.scales = null;
            
            System.debug('retrieveChartDataExample [datasets lodaed ] ');
            strJSON = JSON.serialize(objChartData, true);
            
        } catch (Exception Ex) {
            System.debug('Ex : ' + Ex.getMessage() );
            System.debug('Ex : ' + Ex.getStackTraceString() );
        }
        
        System.debug('retrieveChartDataExample [ ' + strJSON + ' ] <- ');
        return strJSON;
    }
    
    public static Integer generateRandomNumber(Integer intMaxValue){
        Double dblRandomNumber = 0;
        
        dblRandomNumber = Math.random() * intMaxValue;
        
        return dblRandomNumber.intValue();
     }
}