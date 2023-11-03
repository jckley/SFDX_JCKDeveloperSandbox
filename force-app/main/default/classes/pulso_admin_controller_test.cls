@istest
public class pulso_admin_controller_test {
	@testsetup
    public static void inicializeTest() {
		CommonTestFunctions testSet = new CommonTestFunctions();
		testSet.createNewSurveyForTest();
    }
     
    @istest
    public static void metodoDePrueba() {
        pulso_admin_controller objPulsoController = null;
        RemotingMessageHelper.Encuesta objSurvey = null;
        
        pulso_admin_controller.retrieveSurveyInfo(NULL);
        pulso_admin_controller.retrieveSurveyInfo([SELECT TypeformId__c FROM Encuesta__c].TypeformId__c);
        
        objPulsoController = new pulso_admin_controller();
        objPulsoController.ListaDeDatosEncuestas = NULL;
        objPulsoController.NombreEncuesta = NULL;
        objPulsoController.StatsCantidadEncuestas = NULL;
        objPulsoController.StatsCantidadPreguntas = NULL;
        objPulsoController.StatsPersonasEncuestadas = NULL;
        objPulsoController.StatsEncuestasCompletas = NULL;
        objPulsoController.StatsCuitificados = NULL;
        objPulsoController.StatsTimeSinceLastUpdate = NULL;
        objPulsoController.dotColor = NULL;
        objPulsoController.surveystatus = NULL;
        objPulsoController.SurveyId = NULL;
        objPulsoController.OnlyCuitificados = NULL;
        objPulsoController.survey = NULL;
        
        
        
        objSurvey = new RemotingMessageHelper.Encuesta ();
        objSurvey.surveyid = 'test';
        objSurvey.responseid = 'test';
        objSurvey.name = 'test';
        objSurvey.advertising = 'test';
        objSurvey.description = 'test';
        objSurvey.slug = 'test';
        
        pulso_admin_controller.upsertSurvey(JSON.serialize(objSurvey));
        /*
        List <RemotingMessageHelper.PulsoSurvey> encuestas = pulso_admin_controller.ObtenerEncuestas();
        system.assertEquals(1, encuestas.size());
        
        pulso_admin_controller controller = new pulso_admin_controller();
        controller.ObtenerDatosEncuesta(encuestas[0].Id);
        
        String encuestajson = '{"typeformid":"id-encuesta-test","resultadosid":"id-resultados-test","tituloencuesta":"Nueva Encuesta test","pauta":"Twitter / Facebook","slug":"nueva_encuesta_test","descripcion":"Descripción de la Nueva Encuesta test..."}';
        pulso_admin_controller.InsertarEncuesta(encuestajson);
*/
    }
    
}