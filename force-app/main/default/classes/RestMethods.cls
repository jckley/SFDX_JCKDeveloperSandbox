@RestResource(urlMapping='/rest/*')
global class RestMethods {
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }
    
    @HttpPost
    global static void retrieveCUITS(RemotingMessageHelper.CUITRequest[] request) {
        RemotingMessageHelper.CUITResponse[] lstResponse = null;
        RemotingMessageHelper.CUITResponse objResponse = null;
        RestResponse objRESTResponse = null;
		List<RemotingMessageHelper.CUITRequest> lstContactRequest = null;   
        List<RemotingMessageHelper.CitizenFound> lstCitizensFound = null;
        
        System.debug('retrieveCUIT [ request : ' + request + ' ] -> ');
        System.debug('retrieveCUIT [ RestContext.response : ' + RestContext.response + ' ]');
        try  {            
            lstResponse = new List<RemotingMessageHelper.CUITResponse>();
            objRESTResponse = RestContext.response;
            
            if(request != null && request.size() > 0) {
                if(request.size() < 100) {
                    lstContactRequest  = new List<RemotingMessageHelper.CUITRequest>();
                    for(RemotingMessageHelper.CUITRequest objRequest : request) {                    
                        if(objRequest.isValid()) {
                            lstContactRequest.add(objRequest);                                     
                        } else {
                            objResponse = new RemotingMessageHelper.CUITResponse();
                            objResponse.ExternalId = objRequest.ExternalId;
                            objResponse.Code = 100;
                            objResponse.Message = Label.API_Invalid_Request;
                            lstResponse.add(objResponse);
                        }
                    }

                    if(!lstContactRequest.isEmpty()) {
                        for(RemotingMessageHelper.CUITRequest objRequest : lstContactRequest) {
                           lstCitizensFound = RestMethodsController.retrieveCuits(objRequest);
                             
                            if(lstCitizensFound.isEmpty()) {
                                objResponse = new RemotingMessageHelper.CUITResponse();
                                objResponse.ExternalId = objRequest.ExternalId;
                                objResponse.Code = 120;
                                objResponse.Message = Label.API_CUIT_Not_found;
                            } else if(lstCitizensFound.size() == 1) {
                                objResponse = new RemotingMessageHelper.CUITResponse();
                                objResponse.ExternalId = objRequest.ExternalId;
                                objResponse.Code = 0;
                                objResponse.CitizensFound = lstCitizensFound;
                                objResponse.Message = Label.API_Success;
                            } else if(lstCitizensFound.size() > 5) {
                                objResponse = new RemotingMessageHelper.CUITResponse();
                                objResponse.ExternalId = objRequest.ExternalId;
                                objResponse.Code = 130;                                 
                                objResponse.Message = label.API_Too_many_results;
                            } else {
                                objResponse = new RemotingMessageHelper.CUITResponse();
                                objResponse.ExternalId = objRequest.ExternalId;
                                objResponse.Code = 140;
                                objResponse.CitizensFound = lstCitizensFound;
                                objResponse.Message = label.API_CUITS_Found;
                            }

                            
                            lstResponse.add(objResponse);
                        }
                    }
                    objRESTResponse.statusCode = 200;
                    objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(lstResponse));    
                } else {
                    objRESTResponse.statusCode = 400;
                    objRESTResponse.responseBody = Blob.valueOf(Label.API_Request_Exceed_Limit);   
                }
            } else {                
                objRESTResponse.statusCode = 400;
            	objRESTResponse.responseBody = Blob.valueOf(Label.API_Request_Null);                
            }
        } catch(Exception Ex) {
            objRESTResponse.statusCode = 500;
            objRESTResponse.responseBody = Blob.valueOf(Label.API_Invalid_Request);                
        }
        
        System.debug('retrieveCUIT [ statusCode : ' + objRESTResponse.statusCode + ' ]');
        System.debug('retrieveCUIT [ responseBody : ' + objRESTResponse.responseBody + ' ]');
        System.debug('retrieveCUIT [] <- ');
    }
}