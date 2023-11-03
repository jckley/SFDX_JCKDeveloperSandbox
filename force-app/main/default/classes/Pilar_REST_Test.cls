@IsTest
public with sharing class Pilar_REST_Test {

    @testSetup
    public static void setupTest() {
        CommonTestFunctions.commonSetup();

        Contact citizen = [SELECT Id, Name FROM Contact LIMIT 1];
        citizen.Document_Number__c = '123456789';
        update citizen;
    }

    @IsTest
    private static void testRest() {

        RestRequest restReq = new RestRequest();
        restReq.requestURI = '/pilar/rest/123456789';
        restReq.httpMethod = 'GET';
        
        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Test.startTest();

        Pilar_REST.cuitificar();

        Test.stopTest();

    }

    @IsTest
    private static void testRest2() {

        RestRequest restReq = new RestRequest();
        restReq.requestURI = '/pilar/rest/123456789';
        restReq.params.put('sexo', 'M');
        restReq.httpMethod = 'GET';
        
        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Test.startTest();

        Pilar_REST.cuitificar();

        Test.stopTest();

    }

    @IsTest
    private static void testRestError() {

        RestRequest restReq = new RestRequest();
        restReq.requestURI = '/pilar/rest/0000000';
        restReq.httpMethod = 'GET';
        
        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Test.startTest();

        Pilar_REST.cuitificar();

        restReq = new RestRequest();
        restReq.requestURI = '/pilar/rest';
        restReq.httpMethod = 'GET';
        
        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Pilar_REST.cuitificar();

        Test.stopTest();

    }
}