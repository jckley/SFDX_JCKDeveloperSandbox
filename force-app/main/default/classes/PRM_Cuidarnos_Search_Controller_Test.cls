@IsTest
private  with sharing class PRM_Cuidarnos_Search_Controller_Test {
    @IsTest
    private static void cuidarnosSearchTest() {

        PRM_Cuidarnos_Search_Controller.retrieveCitizens();
        PRM_Cuidarnos_Search_Controller.searchCitizen('juan',10); 
    }

}