@IsTest
public with sharing class Pilar360ControllerTest {
    @IsTest
    private static void testController() {
        Pilar360Controller.retrieveInteractions('0036A000008o6N6QAI');
        Pilar360Controller.retrieveStats('0036A000008o6N6QAI');
        Pilar360Controller.retrievePilarRecord('0036A000008o6N6QAI');
        Pilar360Controller.retrievePrograms();
    }
}