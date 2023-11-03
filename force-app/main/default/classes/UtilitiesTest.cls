/**
* Class Name: UtilitiesTest
* Description: Test Class for the Utilities class
* Developer: Luis Puentes - Date: 06/06/2018
*/

@isTest
public class UtilitiesTest {
    
    @isTest 
    static void testGetFieldLabel() {
        
        String sObjectType = 'Contact';
        String field = 'FirstName';
        System.assertEquals('First Name', Utilities.getFieldLabel(field, sObjectType));
    }
    
    @isTest 
    static void testGetFieldType() {
        
        String sObjectType = 'Contact';
        String field = 'FirstName';
        System.assertEquals('STRING', Utilities.getFieldtype(field, sObjectType));
    }
    
    @isTest 
    static void testGetThousandSeparatedByDotWithMillions() {
        
        Integer numberWithMillions = 1000000;
        System.assertEquals('1.000.000', Utilities.getThousandSeparatedByDot(numberWithMillions));
    }
    
    @isTest 
    static void testGetThousandSeparatedByDotWithThousand() {
        
        Integer numberWithThousand = 1000;
        System.assertEquals('1.000', Utilities.getThousandSeparatedByDot(numberWithThousand));
        
    }
    
    @isTest
    static void testGetRemoveAccents () {
        
        String stringWithAccents = 'Córdoba';
        System.assertEquals('Cordoba', Utilities.removeAccents(stringWithAccents));
    }
    
    @isTest
    static void testPicklistMethods () {
        
        String plObject = 'Contact';
        String plField = 'Community__c';
        //Test retrivePicklistValues
        List<Schema.PicklistEntry> ple = Utilities.retrievePicklistValues(plObject, plField);
        System.assertEquals(true, ple.size() > 0);
        Test.startTest();
        //Test buildPicklistOptions
        List<SelectOption> plo = Utilities.buildPickListOptions(ple);
        System.assertEquals(true, plo.size() > 0);
        //Test addValueToPicklist
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        Utilities.addValueToPickList(plObject, plField, true, 'test');
        Test.stopTest();
    }
    
}