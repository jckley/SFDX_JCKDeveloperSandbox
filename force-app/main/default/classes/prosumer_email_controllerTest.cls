@isTest
public class prosumer_email_controllerTest {

    @isTest
    public static void getEmailRecordTest () {
        Prosumer_Email__c emailRecord = new Prosumer_Email__c ();
        emailRecord.name = 'TestEmail';
        insert emailRecord;
        prosumer_email_controller.getEmailRecord(emailRecord.id);
    }

    @isTest
    public static void getEmailListTest () {
        prosumer_email_controller.getEmailList();
    }

    @isTest
    public static void updateEmailRecordTest () {
        Prosumer_Email__c emailRecord = new Prosumer_Email__c ();
        emailRecord.name = 'TestEmail';
        insert emailRecord;

        Map<String,String> jsonObject = new Map<String,String>();
        jsonObject.put('nombreDelMail','Otro nombre');
        String jsonString = JSON.serialize(jsonObject);
        String htmlString = '<h1>Test</h1>';
        prosumer_email_controller.updateEmailRecord(emailRecord.id, htmlString, jsonString);
    }

    @isTest
    public static void createEmailRecordTest () {
        Map<String,String> jsonObject = new Map<String,String>();
        jsonObject.put('nombreDelMail','TestEmail');
        String jsonString = JSON.serialize(jsonObject);
        String htmlString = '<h1>Test</h1>';
        prosumer_email_controller.createEmailRecord(htmlString, jsonString);
    }
}