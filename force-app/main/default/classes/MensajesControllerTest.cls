@isTest
public class MensajesControllerTest {
	@testSetup
    private static void setupTest() {
        Project__c objProject = new Project__c();
        objProject.Prioridad__c = 2;
        objProject.Objetivo__c = 'objetivo';
        insert objProject;
        
        Campania__c campania = new Campania__c (Project__c = objProject.Id, name='Campaña de navidad', StartDate__c=Date.newInstance(2019, 7, 7), Status__c='FINALIZADA');
        insert campania;
        
        Message__c mensaje = 
            new Message__c (
                Campania__c = campania.Id,
                name='Título de este mensaje que es un poco medio largo', 
                SendDateTime__c=DateTime.newInstance(2018, 11, 8, 11, 03, 00),
                Body__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                TotalsSent__c = 5000108,
            TotalsAudience__c = 2078865,
           // ImpXPersona__c = 1.2,
            CantSuccess__C = 4991320,
                CantRejected__c = 2078865
            //CantResponses__c = 429913
            );
        insert mensaje;
    }
    
    @isTest
    private static void crearCampaniaTest() {
        List<Campania__c> listaDeCampanias = MensajesController.campanias(null);
        
        System.assertEquals(1, listaDeCampanias.size());
    }
    
    
    @isTest
    private static void crearMensajeTest() {
        List<Message__c> listaDeMensajes = MensajesController.mensajes(null);
        
        MensajesController.elmejortestlohacelusuarioenproduccion();
        //System.assertEquals(1, listaDeMensajes.size());
    }
}