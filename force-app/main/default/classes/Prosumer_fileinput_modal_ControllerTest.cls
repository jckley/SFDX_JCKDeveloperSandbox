@isTest
public class Prosumer_fileinput_modal_ControllerTest {

    @TestSetup
    static void makeData(){
        ContentVersion cv = new ContentVersion ();
        cv.title = 'test file';
        cv.PathOnClient = '/testfile.txt';
        //guarda cualquier cosa porque el string original deberia tener un formato especial. 
        cv.VersionData = Blob.valueof('Hooola');
        insert cv;
    }

    @isTest
    public static void getFilesTest() {
        //es una query nomas. Lo unico raro es que debe traer solamente los files asociados a la cuenta del usuario
        List<String> extensionesDeArchivos = new List<String>();
        extensionesDeArchivos.add('.jpg');
        Prosumer_fileinput_modal_Controller.getFiles(extensionesDeArchivos);
    }

    @isTest
    public static void createLinkForContentVersionIdTest(){
        //contentVersion lo esta creando el componente usando el Lightning Data Service
        Prosumer_fileinput_modal_Controller.createLinkForContentVersionId(getContentVersionId());
    }

    @isTest
    public static void getContentVersionDataAsStringTest(){
        Prosumer_fileinput_modal_Controller.getContentVersionDataAsString(getContentVersionId());
    }

    @isTest
    public static void deleteDocumentFromContentVersionIdTest(){
        Prosumer_fileinput_modal_Controller.deleteDocumentFromContentVersionId(getContentVersionId());
    }

    public static id getContentVersionId(){
        ContentVersion cv = [SELECT id FROM ContentVersion];
        return cv.id;
    }
}