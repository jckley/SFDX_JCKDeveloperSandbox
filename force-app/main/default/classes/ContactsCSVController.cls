public class ContactsCSVController {
    
    public string nameFile{get;set;}
    public transient Blob contentFile{get;set;}
    public String contentFileString{get;set;}
    public String pageMessage {get;set;}
    public Boolean isSuccessMessage {get;set;}
    Public String selectedSearchCriteria {get;set;}
    Public List<SelectOption> posibleCriteriaOptions {get;set;}
    String[] filelines = new String[]{};
        List<Contact> contacts;
    
    public ContactsCSVController(){ 
        posibleCriteriaOptions=new List<SelectOption>();
        SelectOption A1= new SelectOption('SearchCriteria__c','Cuitificador x Campo Mixto');
        SelectOption A2= new SelectOption('MobilePhone','Cuitificador x Celular');
        SelectOption A3= new SelectOption('Email','Cuitificador x Email');
        posibleCriteriaOptions.add(A1);
        posibleCriteriaOptions.add(A2);
        posibleCriteriaOptions.add(A3);
    }
    
    public void ReadFile() {
        System.debug('opcion seleccionada: ' + selectedSearchCriteria);
        if(contentFile != NULL){
            contentFileString = contentFile.toString();
            
            if(contentFileString.length() < 1000000){
                filelines = contentFileString.split('\n');
                if(filelines.size() <= 1){
                    isSuccessMessage = false;
                    pageMessage = 'Por favor adjunte un archivo CSV válido.';
                }else if(filelines.size() > 1 && filelines.size() <= 7500){
                    List<String> mixList =new List<String>();
                    if(filelines[1].split(';').size() > 1){
                        for(Integer i=1; i<filelines.size(); i++){
                            if(filelines[i].split(';')[1].trim() != ''){
                                mixList.add( filelines[i].split(';')[1].replace('\r','').replace('\n',''));
                            }            
                        }
                    }else if(filelines[1].split(',').size() > 1){
                        for(Integer i=1; i<filelines.size(); i++){
                            if(filelines[i].split(',')[1].trim() != ''){
                                mixList.add( filelines[i].split(',')[1].replace('\r','').replace('\n',''));
                            }            
                        }
                    }
                    
                    ContactsCSVBatch CSVBatch = new ContactsCSVBatch();
                    System.debug('criterio: ' + mixList);
                    CSVBatch.searchCriteria = mixList;
                    CSVBatch.whereCondition = selectedSearchCriteria;
                    Database.executeBatch(CSVBatch, 10000);
                    
                    isSuccessMessage = true;
                    pageMessage = 'La operación se realizó correctamente';
                    
                }else{
                    isSuccessMessage = false;
                    pageMessage = 'El archivo tiene demasiadas lineas, adjunte un archivo de menor tamaño.';
                }
            }else{
                contentFileString = '';
                isSuccessMessage = false;
                pageMessage = 'El contenido del archivo excede el maximo permitido.';
            }
        }else{
            isSuccessMessage = false;
            pageMessage = 'Por favor adjunte un archivo.';
        }
    }
}