@isTest
public class RiverEncuestasControllerTest {
    @isTest
    public static void RiverEncuestasControllerTest() {
        RiverId__c rvid = new RiverId__c();
        Insert rvid;

        List<RiverId_Polls__c> rvPolls = new List<RiverId_Polls__c> ();
        rvPolls.add(new RiverId_Polls__c(
            RiverId_SFID__c = rvid.id,
            River_Name__c = 'Encuesta 1',
            Token__c = 'token1',
            guid__c = 'guid1'
        ));
        rvPolls.add(new RiverId_Polls__c(
            RiverId_SFID__c = rvid.id,
            River_Name__c = 'Encuesta 1',
            Token__c = 'token2',
            guid__c = 'guid2'
        ));
        rvPolls.add(new RiverId_Polls__c(
            RiverId_SFID__c = rvid.id,
            River_Name__c = 'Encuesta 2',
            Token__c = 'token3',
            guid__c = 'guid3'
        ));
        Insert rvPolls;
        Test.startTest();
        List<AggregateResult> resutls = RiverEncuestasController.getGroupedEncuestas();
        Test.stopTest();
        System.debug(resutls);
    }
}