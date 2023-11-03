@isTest 
public class Municipio_HomeControllerTest {   
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }
    
    @isTest  
    static void test1() {              
        Municipio_HomeController pcc = new Municipio_HomeController();
        Municipio_HomeController.getRootTerritory();
    }
}