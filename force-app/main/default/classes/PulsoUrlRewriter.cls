global with sharing class PulsoUrlRewriter implements Site.UrlRewriter {    
    String DIRECTORY = '/';
    String VISUALFORCE_PAGE = '/pulso?surveyid=';
    
    global PulsoUrlRewriter() {
        Survey_Setting__mdt objSurveySettings = null;
        
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        DIRECTORY = objSurveySettings.UrlRewriterPath__c;
        VISUALFORCE_PAGE = objSurveySettings.UrlRewriterVF__c;                
    }
     
    global PageReference mapRequestUrl(PageReference objFriendlyPageReference) {                 
        String strUrl = null;
        String strSlug = null;
        String strQueryString = null;
        List<Encuesta__c> lstSurveys = null;
        PageReference objUglyPageReference = null;
        //
        System.debug('mapRequestUrl [objFriendlyPageReference : ' + objFriendlyPageReference + '] ->');
        strUrl = objFriendlyPageReference.getUrl();
        
        if(String.isNotBlank(strUrl) && strUrl.startsWith(DIRECTORY)){      
            System.debug('mapRequestUrl [strUrl : ' + strUrl + ']');

            strSlug = strUrl.substring(DIRECTORY.length(), strUrl.length());
            if(strSlug.indexOf('?') >= 0) {
                strSlug = strSlug.substring(0, strSlug.indexOf('?'));
            }
            
            System.debug('mapRequestUrl [strSlug : ' + strSlug + ']');

            if(String.isNotBlank(strSlug)) {
                lstSurveys = [SELECT TypeformId__c 
                              FROM Encuesta__c 
                              WHERE Slug__c = :strSlug
                              LIMIT 1];
                System.debug('mapRequestUrl [lstSurveys : ' + lstSurveys + ']');

                 
                if(!lstSurveys.isEmpty()) {                    
                    objUglyPageReference = new PageReference(VISUALFORCE_PAGE);
                    
                    objUglyPageReference.getParameters().put('surveyid', lstSurveys[0].TypeformId__c );
                    
                    if(objFriendlyPageReference.getParameters() != NULl && !objFriendlyPageReference.getParameters().isEmpty()) {
                        for(String strParameter : objFriendlyPageReference.getParameters().keySet()) {
                            objUglyPageReference.getParameters().put(strParameter, objFriendlyPageReference.getParameters().get(strParameter));                         
                        }                    
                    }
                }
            } 
        } else {
            System.debug('mapRequestUrl [strUrl : ' + strUrl + ' - DIRECTORY ' + DIRECTORY + ']');
        }
        
        System.debug('mapRequestUrl [' + objUglyPageReference + '] <-');

        return objUglyPageReference;    
    }
    
    global List<PageReference> generateUrlFor(List<PageReference>  lstUglyPageReferences){
        List<PageReference> lstFriendlyPageReferences = null;
        PageReference objFriendlyPageReference = null;
        String strUglyUrl = null;
        String strSurveyId = null;
        List<Encuesta__c> lstSurveys = null;

        System.debug('generateUrlFor [lstUglyPageReferences : ' + lstUglyPageReferences + '] ->');

        lstFriendlyPageReferences = new List<PageReference>();
        
        for(PageReference objUglyPageReference : lstUglyPageReferences){
            strUglyUrl = objUglyPageReference.getUrl();
               
            if(strUglyUrl.startsWith(VISUALFORCE_PAGE)){                
                strSurveyId = strUglyUrl.substring(VISUALFORCE_PAGE.length(), strUglyUrl.length());
                
                if(String.isNotBlank(strSurveyId)) {
                    System.debug('strSurveyId : ' + strSurveyId);
                    lstSurveys = [SELECT Slug__c 
                                  FROM Encuesta__c 
                                  WHERE TypeformId__c =:strSurveyId 
                                  LIMIT 1];
                    
                    objFriendlyPageReference = new PageReference(DIRECTORY + lstSurveys[0].Slug__c);
                }
            } else {
                objFriendlyPageReference = new PageReference(strUglyUrl);
            }    
            
            lstFriendlyPageReferences.add(objFriendlyPageReference);
        }

        System.debug('generateUrlFor [' + lstFriendlyPageReferences + '] <-');
        
        return lstFriendlyPageReferences;
    }
}