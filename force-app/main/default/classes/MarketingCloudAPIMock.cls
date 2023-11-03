global class MarketingCloudAPIMock implements HttpCalloutMock {    
    global HttpResponse respond(HTTPRequest objRequest) {
        HttpResponse objResponse = null;
        
        objResponse = new HttpResponse();
        objResponse.setStatus('OK');
        objResponse.setStatusCode(202);
        if(objRequest.getEndpoint().contains('requestToken')) {
             objResponse.setBody('{"accessToken": "ZaOXjqm8iwfXELY80ylohBPf","expiresIn": 3479}');
        } else if(objRequest.getEndpoint().contains('queueMO')) {
            objResponse.setBody('{"results": [{"identifier": "b18wbjlhUDJHa21BdGpJcVFjMEhtdzo3Njow","mobileNumber": "541167304156","result": "OK"}]}');
        } else if(objRequest.getEndpoint().contains('messageContact')) {
            objResponse.setBody('{ "tokenId": "SENiV0xSSi1OVVdXV3lPdk9nV0Qwdzo3Njox" }');
        } else if(objRequest.getEndpoint().contains('messaging')) {
            objResponse.setBody('{"requestId": "a2a1a9a8-7b34-42b4-924f-b07129c76c97", "responses": [ {"recipientSendId": "a2a1a9a8-7b34-42b4-924f-b07129c76c97","hasErrors": false,"messages": ["Queued"],}],}');
        }
       
        return objResponse;
    } 
    
    public MarketingCloudAPIMock() {}
}