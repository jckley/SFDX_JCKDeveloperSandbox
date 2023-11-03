global class RESTMock  implements HttpCalloutMock {   
    private Integer intStatusCode = 0;
    
    public RESTMock() {}
    
    global HttpResponse respond(HTTPRequest objRequest) {
        HttpResponse objResponse = null;
        
        objResponse = new HttpResponse();
        objResponse.setStatus('OK');
        objResponse.setStatusCode(200);
        
        objResponse.setBody('{"reportMetadata" : { "reportType" : { "type"  : "test" } } }');
        
        return objResponse;
    } 
}