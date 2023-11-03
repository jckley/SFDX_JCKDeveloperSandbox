@IsTest
private class Pulso_Contact_Modal_Controller_Test {
    @IsTest
    private static void saveContactTest() {
        RemotingMessageHelper.PulsoContact objContact = null;
        
        objContact = new RemotingMessageHelper.PulsoContact();
        objContact.FirstName = 'Juan';
        objContact.LastName = 'Perez';
        objContact.Email = 'juanperez@salesforce.com';
        objContact.Mobile = '11222333';
        objContact.Description = 'Consulta de test';
        
        System.assertEquals(0, [SELECT Id FROM Lead].size());
        
        Pulso_Contact_Modal_Controller.saveContact(JSON.serialize(objContact));
        
        System.assertEquals(1, [SELECT Id FROM Lead].size());

    }
    
    
}