/**
 * ClassName: ContactWrapper
 * Description: Auxiliar class for the TerritoryDetailController
 * Developer: Luis Puentes - Date: 30/05/2018
*/
public class TerritoryWrapper {   
    @AuraEnabled
    public Territorio_Administrativo__c territory { get; set; }
    
    /*data*/
	@AuraEnabled    
    public String territoryName {get;set;}
    @AuraEnabled
   	public String territoryNameDetail {get;set;}
    @AuraEnabled
    public String territoryLabel {get;set;}
    @AuraEnabled
    public String partentTerritoryName {get;set;}
    @AuraEnabled
    public String totalCiudadanosFormated {get;set;}
    @AuraEnabled
    public String totalemailsFormated {get;set;}
    @AuraEnabled
    public String totalMobilesFormated {get;set;}
    @AuraEnabled
    public String totalLandingFormated {get;set;}  
    @AuraEnabled
    public String totalSocialFormated {get;set;}
    @AuraEnabled
    public String totalFacebookFormated {get;set;}
    @AuraEnabled
    public String totalInstagramFormated {get;set;}
    @AuraEnabled
    public String totalTwitterFormated {get;set;}
    @AuraEnabled
    public String totalLinkedinFormated {get;set;}
    @AuraEnabled
    public Decimal totalMenPerc {get;set;}
    @AuraEnabled
    public Decimal totalWomenPerc {get;set;}
    @AuraEnabled
    public String pyramidValues {get;set;}
    @AuraEnabled
    public PyramidValues[] pyramidValuesLightning {get;set;}
    @AuraEnabled
    public String parentId {get;set;}
    @AuraEnabled
    public List<String> labelsAux {get;set;}
    @AuraEnabled
    public List<Decimal> menCount {get;set;}
    @AuraEnabled
    public List<Decimal> womenCount {get;set;}
    @AuraEnabled
    public Decimal totalMen;
    @AuraEnabled
    public Decimal totalWomen;
    @AuraEnabled
    public String totalMenFormated;
    @AuraEnabled
    public string totalWomenFormated;
    @AuraEnabled
    public Territorio_Administrativo__c ter0;
    @AuraEnabled
    public Territorio_Administrativo__c ter1;
    @AuraEnabled
    public Territorio_Administrativo__c ter2;
    @AuraEnabled
    public Territorio_Administrativo__c ter3;
    @AuraEnabled
    public Territorio_Administrativo__c ter4;
    private Decimal totalBoth;
    
    public TerritoryWrapper (Territorio_Administrativo__c terr){
        territory = terr;
        
        ter0 = new Territorio_Administrativo__c();
        ter1 = new Territorio_Administrativo__c();
        ter2 = new Territorio_Administrativo__c();
        ter3 = new Territorio_Administrativo__c();
        ter4 = new Territorio_Administrativo__c();
        
        if(territory.Nivel_Administrativo__c == 0){
            //territoryName = territory.Nivel_Administrativo_0__c;
            territoryName = territory.Level0Name__c;
            territoryLabel = Utilities.getFieldLabel('Level0Name__c','Territorio_Administrativo__c');
            
            ter0.Id = territory.Id;
            ter0.Name = territory.Name;
            
        }else if(territory.Nivel_Administrativo__c == 1){
            //territoryName = territory.Nivel_Administrativo_1__c;
            territoryName = territory.Level1Name__c;
            territoryLabel = Utilities.getFieldLabel('Level1Name__c','Territorio_Administrativo__c');
            
            ter1.Id = territory.Id;
            ter1.Name = territory.Name;
            ter0.Id = territory.ParentId__c;
            ter0.Name = territory.ParentId__r.Name;
            
        }else if(territory.Nivel_Administrativo__c == 2){
            //territoryName = territory.Nivel_Administrativo_2__c;
            territoryName = territory.Level2Name__c;
            territoryLabel = Utilities.getFieldLabel('Level2Name__c','Territorio_Administrativo__c');
            
            ter2.Id = territory.Id;
            ter2.Name = territory.Name;
            ter1.Id = territory.ParentId__c;
            ter1.Name = territory.ParentId__r.Name;
            ter0.Id = territory.ParentId__r.ParentId__c;
            ter0.Name = territory.ParentId__r.ParentId__r.Name;
            
        }else if(territory.Nivel_Administrativo__c == 3){
            //territoryName = territory.Nivel_Administrativo_3__c;
            territoryName = territory.Level3Name__c;
            territoryLabel = Utilities.getFieldLabel('Level3Name__c','Territorio_Administrativo__c');
            
            ter3.Id = territory.Id;
            ter3.Name = territory.Name;
            ter2.Id = territory.ParentId__c;
            ter2.Name = territory.ParentId__r.Name;
            ter1.Id = territory.ParentId__r.ParentId__c;
            ter1.Name = territory.ParentId__r.ParentId__r.Name;
            ter0.Id = territory.ParentId__r.ParentId__r.ParentId__c;
            ter0.Name = territory.ParentId__r.ParentId__r.ParentId__r.Name;
            
        }else if(territory.Nivel_Administrativo__c == 4){
            //territoryName = territory.Nivel_Administrativo_4__c;
            territoryName = territory.Level4Name__c;
            territoryLabel = Utilities.getFieldLabel('Level4Name__c','Territorio_Administrativo__c');
            
            ter4.Id = territory.Id;
            ter4.Name = territory.Name;
            ter3.Id = territory.ParentId__c;
            ter3.Name = territory.ParentId__r.Name;
            ter2.Id = territory.ParentId__r.ParentId__c;
            ter2.Name = territory.ParentId__r.ParentId__r.Name;
            ter1.Id = territory.ParentId__r.ParentId__r.ParentId__c;
            ter1.Name = territory.ParentId__r.ParentId__r.ParentId__r.Name;
            ter0.Id = territory.ParentId__r.ParentId__r.ParentId__r.ParentId__c;
            ter0.Name = territory.ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name;
            
        }
        List<String> ageRangeMaleInfo = new List<String>{'Total_de_Hombres_de_0_a_15__c', 'Total_de_Hombres_de_16_a_17__c', 'Total_de_Hombres_de_18_a_24__c', 'Total_de_Hombres_de_25_a_39__c', 'Total_de_Hombres_de_40_a_64__c', 'Total_Hombres_de_65plus__c'};
        List<String> ageRangeFemaleInfo = new List<String>{'Total_Mujeres_de_0_a_15__c', 'Total_Mujeres_de_16_a_17__c', 'Total_Mujeres_de_18_a_24__c', 'Total_Mujeres_de_25_a_39__c', 'Total_Mujeres_de_40_a_64__c', 'Total_Mujeres_de_65plus__c'};
        menCount = new List<Decimal>();
        womenCount = new List<Decimal>();
        totalMen = 0;
        totalWomen = 0;
        Integer auxCont = 0;
        Integer auxSum = 0;
        for(String field : ageRangeMaleInfo){
            if((Decimal)territory.get(field) != NULL){
                totalMen += (Decimal)territory.get(field);
                if(auxCont == 1){
                	menCount.add(totalMen);    
                } else if (auxCont > 1){
                    menCount.add((Decimal)territory.get(field));
                }
                auxCont++;
            }
        }
        auxCont = 0;
        for(String field : ageRangeFemaleInfo){
            if((Decimal)territory.get(field) != NULL){
                totalWomen += (Decimal)territory.get(field);
                if(auxCont == 1){
                	womenCount.add(totalWomen);    
                } else if (auxCont > 1){
                    womenCount.add((Decimal)territory.get(field));
                }
                auxCont++;
            }
        }
        
        /*for(String field : ageRangeMaleInfo){
            if((Decimal)territory.get(field) != NULL){
                totalMen += (Decimal)territory.get(field);
                menCount.add((Decimal)territory.get(field));

            }
        }
        for(String field : ageRangeFemaleInfo){
            if((Decimal)territory.get(field) != NULL){
                totalWomen += (Decimal)territory.get(field);
                womenCount.add((Decimal)territory.get(field));
            }
        }*/
        
        totalBoth = totalMen + totalWomen;
        totalMenFormated = Utilities.getThousandSeparatedByDot((Integer)totalMen);
        totalWomenFormated = Utilities.getThousandSeparatedByDot((Integer)totalWomen);
        
        parentId = territory.ParentId__c;
        partentTerritoryName = territory.ParentId__r.Name;
        totalCiudadanosFormated = territory.Total_Ciudadanos__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Ciudadanos__c)) : '-';
        totalemailsFormated = territory.Total_Emails__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Emails__c))  : '-';
        totalLandingFormated = territory.Total_Telefonos_FIjos__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Telefonos_FIjos__c)) : '-';
        totalMobilesFormated = territory.Total_Moviles__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Moviles__c)) : '-';
        totalSocialFormated = territory.Social_Profiles__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Social_Profiles__c)) : '-';
        totalFacebookFormated = territory.Total_Facebook__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Facebook__c)) : '-';
        totalInstagramFormated = territory.Total_Instagram__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Instagram__c)) : '-';
        totalTwitterFormated = territory.Total_Twitter__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Twitter__c)) : '-';
        totalLinkedinFormated = territory.Total_Linkedin__c != NULL ? Utilities.getThousandSeparatedByDot(Integer.valueof(territory.Total_Linkedin__c)) : '-';
        
        List<String> labels = new List<String>{'0-15', ' 16-17', '18-24', '25-39', '40-64', '65+'};
        labelsAux = new List<String>{'0-17', '18-24', '25-39', '40-64', '65+'};
        
            if(totalBoth > 0){
            totalMenPerc = ((totalMen/totalBoth)*100).setScale(2);
            totalWomenPerc = ((totalWomen/totalBoth)*100).setScale(2);
            pyramidValues = retrievePyramidValues(territory, ageRangeMaleInfo, ageRangeFemaleInfo, labels);
            pyramidValuesLightning = retrievePyramidValuesLightning(territory, ageRangeMaleInfo, ageRangeFemaleInfo, labels);
        }
        
        territoryNameDetail = String.format('{0} , {1}', new String[] {Label.Territory, territoryLabel});
        
        if(String.isNotBlank(this.partentTerritoryName)) {
         	territoryNameDetail += ' , ' + Label.ParentTerritory + ' : ';    
        }
    }
    
    /*
    * Name: retrievePyramidValues
    * Description: gets the values for the poblational pyramid
    */
    public String retrievePyramidValues(Territorio_Administrativo__c territory, List<String> maleField, List<String> femaleField, List<String> labels) {
        PyramidValues[] lstValues = new List<PyramidValues>();
        PyramidValues objPyramid = null;

        for(Integer intI = 0; intI < 6; intI++) {
            objPyramid = new PyramidValues();
            objPyramid.Label = labels[intI];
            objPyramid.Right = (Decimal)territory.get(maleField[intI]);
            objPyramid.Left = (Decimal)territory.get(femaleField[intI]);
            
            lstValues.add(objPyramid);
        }
        return JSON.serialize(lstValues);
    }
    
    /*
    * Name: retrievePyramidValues
    * Description: gets the values for the poblational pyramid
    */
    public PyramidValues[] retrievePyramidValuesLightning(Territorio_Administrativo__c territory, List<String> maleField, List<String> femaleField, List<String> labels) {
        PyramidValues[] lstValues = new List<PyramidValues>();
        PyramidValues objPyramid = null;
        Decimal total = 0;
        for(Integer i = 0; i < maleField.size(); i++) {
            Decimal totalMale = (Decimal)territory.get(maleField[i]);
            if(totalMale==null) totalMale = 0;
            Decimal totalFemale = (Decimal)territory.get(femaleField[i]);
            if(totalFemale==null) totalFemale = 0;
            
            total += totalMale + totalFemale;
        }

        for(Integer intI = 0; intI < 6; intI++) {
            objPyramid = new PyramidValues();
            objPyramid.Label = labels[intI];

            Decimal totalMale = (Decimal)territory.get(maleField[intI]);
            if(totalMale==null) totalMale = 0;
            Decimal totalFemale = (Decimal)territory.get(femaleField[intI]);
            if(totalFemale==null) totalFemale = 0;

            objPyramid.Right = (totalMale/total)*100;
            objPyramid.Left = (totalFemale/total)*100;
            
            lstValues.add(objPyramid);
        }
        return lstValues;
    }

}