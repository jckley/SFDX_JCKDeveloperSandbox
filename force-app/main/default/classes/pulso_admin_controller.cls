public class pulso_admin_controller {
    @RemoteAction
    public static RemotingMessageHelper.Encuesta retrieveSurveyInfo(String strSurveyId) {
        RemotingMessageHelper.Encuesta objSurvey = null;        
        List<Encuesta__c> lstSurveys = null;

		System.debug('retrieveSurveyInfo [strSurveyId : ' + strSurveyId + '] ->');  
        
        if(String.isNotBlank(strSurveyId)) {
            lstSurveys = [SELECT Id, TypeformId__c, Default_Survey__c, TypeformResultsId__c, TituloEncuesta__c,AdvertinsingID__c, Slug__c, Description__c, Number_Of_Questions__c 
                            FROM Encuesta__c 
                            WHERE TypeformId__c = :strSurveyId];
            
            if(!lstSurveys.isEmpty()) {
                objSurvey = new RemotingMessageHelper.Encuesta(lstSurveys[0]);
            }
        }
        
        System.debug('retrieveSurveyInfo [] <-');
        return objSurvey;
    }
   
    
    @RemoteAction 
    public static void upsertSurvey(String strJSON) {
        RemotingMessageHelper.Encuesta objSurvey = null;
        Encuesta__c objSurveyC = null;
        
        System.debug('upsertSurvey [strJSON : ' + strJSON + '] ->');  
        
        try {
            objSurvey = (RemotingMessageHelper.Encuesta) JSON.deserialize(strJSON, RemotingMessageHelper.Encuesta.class);
            objSurveyC = new Encuesta__c();
            
            objSurveyC.TypeformId__c = objSurvey.surveyid;
            objSurveyC.TypeformResultsId__c = objSurvey.responseid;
            objSurveyC.TituloEncuesta__c = objSurvey.name;
            objSurveyC.AdvertinsingID__c = objSurvey.advertising;
            objSurveyC.Description__c = objSurvey.description;
            objSurveyC.Slug__c = objSurvey.slug;
            
            upsert objSurveyC TypeformId__c;    
            
        } catch (Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);            
        }
        
        System.debug('upsertSurvey [] <-');    
    }

    public List <datos_encuesta> ListaDeDatosEncuestas {get; set;}
    public String NombreEncuesta {get; set;}
    public Integer StatsCantidadEncuestas {get; set;}
    public Integer StatsCantidadPreguntas {get; set;}
    public Integer StatsPersonasEncuestadas {get; set;}
    public Integer StatsEncuestasCompletas {get; set;}
    public Integer StatsCuitificados {get; set;}
    public String StatsTimeSinceLastUpdate {get; set;}
    public String dotColor {get; set;}
    public String surveystatus {get; set;}
    public String SurveyId {get; set;}
    public Boolean OnlyCuitificados {get; set;}
    public RemotingMessageHelper.Encuesta survey {get; set;}
    /*
  

        
    public pulso_admin_controller() {
        / *
        SurveyId = ApexPages.currentPage().getParameters().get('survey_id');
        if (surveyId != NULL) {
	        ObtenerDatosEncuesta(SurveyId);
        }
* /
    }

    @RemoteAction
    public static Long retrieveLeadsCuitificados () { 
    	Long lngCuitificados = null;
        
        lngCuitificados = [SELECT count() 
                           FROM User_Survey__c 
                           WHERE Lead__r.Citizen__c != NULL 
                           AND Survey__r.Enabled__c = TRUE
                           AND Lead__r.RecordType.DeveloperName = 'PulsoCRM'];

        return lngCuitificados;
    }
    
    @RemoteAction
    public static void refreshResults(String strSurveyId) {
        List<Encuesta__c> lstEncuesta = null;
        
        lstEncuesta = [SELECT Id, TypeformId__c 
                       FROM Encuesta__c 
                       WHERE Id =: strSurveyId
                       AND Enabled__c = TRUE];
        
        if(!lstEncuesta.isEmpty()) {
            TypeformAPI.retrieveTypeformSurvey(lstEncuesta[0].TypeformId__c);
        }                
    }
    
        
    @RemoteAction
    public static List <RemotingMessageHelper.PulsoSurvey> ObtenerEncuestas () {
        List <RemotingMessageHelper.PulsoSurvey> ListaDeEncuestas = NULL;
        List <Encuesta__c> encuestasEnSalesforce = NULL;
        List <AggregateResult> lstSurveyStats = NULL;
 		Map<Id, AggregateResult> mapSurveyStats = NULL;
        
        ListaDeEncuestas = new List <RemotingMessageHelper.PulsoSurvey>();        
        
        encuestasEnSalesforce = [SELECT Id, TituloEncuesta__c, Number_Of_Answered_Questions__c, Number_Of_Questions__c, Number_Of_Answering_Users__c, Name 
                                 FROM Encuesta__c
                                 WHERE Enabled__c = TRUE];
        
        lstSurveyStats = [SELECT Survey__c, COUNT(Id) Surveyed, COUNT(Lead__r.Citizen__c) Identified
                          FROM User_Survey__c
                          WHERE Survey__r.Enabled__c = TRUE
                          GROUP BY Survey__c];
        
        mapSurveyStats = new Map<Id, AggregateResult>();
        for(AggregateResult objSurvey : lstSurveyStats) {
            mapSurveyStats.put((Id)objSurvey.get('Survey__c'), objSurvey);
        }
        
        
        for (Encuesta__c encuesta : encuestasEnSalesforce) {
            RemotingMessageHelper.PulsoSurvey survey = new RemotingMessageHelper.PulsoSurvey();
            survey.Id = encuesta.Id;
	        survey.name = encuesta.TituloEncuesta__c;
            survey.preguntas = integer.valueOf(encuesta.Number_Of_Questions__c);
            if( mapSurveyStats.containsKey(encuesta.Id)) { 
                survey.surveyed = (Integer) (mapSurveyStats.get(encuesta.Id)).get('Surveyed');
                survey.identified = (Integer)(mapSurveyStats.get(encuesta.Id)).get('Identified');
            } else {
                survey.surveyed = 0;
                survey.identified = 0;                
            }
            
            ListaDeEncuestas.add (survey);
        }
        
        
        return ListaDeEncuestas;
    }

    public void ObtenerDatosEncuesta (String survey_id) {
        List<Encuesta__c> lstEncuestas = null;
        List<User_Survey__c> lstUserSurvey = null;
        Datetime last = null;
        
        ListaDeDatosEncuestas = new List <datos_encuesta>();
        lstEncuestas = [SELECT Id, TypeformId__c, Default_Survey__c, TypeformResultsId__c, TituloEncuesta__c,AdvertinsingID__c, Slug__c, Description__c 
                        FROM Encuesta__c 
                        WHERE Id = :survey_id
                        AND Enabled__c = TRUE ];
                        
        if(!lstEncuestas.isEmpty()) {
            NombreEncuesta = lstEncuestas[0].TituloEncuesta__c;
            survey = new RemotingMessageHelper.Encuesta(lstEncuestas[0]);
            StatsCantidadPreguntas   = [SELECT count() FROM Survey_Question__c WHERE Survey__c = :survey_id];
            StatsEncuestasCompletas  = [SELECT count() FROM User_Survey__c WHERE Survey__c = :survey_id];
            StatsPersonasEncuestadas = [SELECT count() FROM User_Survey__c WHERE Survey__c = :survey_id and Lead__r.Citizen__c != NULL];
            StatsCuitificados        = [SELECT count() FROM User_Survey__c WHERE Survey__c = :survey_id and Lead__r.Citizen__c != NULL];
            
            //Calcula el tiempo transcurrido desde la última encuesta y realiza
            //la conversión a minutos - horas o días según corresponda
            lstUserSurvey = [SELECT LastModifiedDate FROM User_Survey__c WHERE Survey__c = :survey_id ORDER BY LastModifiedDate DESC LIMIT 1];
            if(lstUserSurvey.IsEmpty()) {
                last = (Datetime)system.now();                
            } else {
                last = (Datetime)lstUserSurvey[0].LastModifiedDate;                
            }         
            
            Datetime now  = (Datetime)system.now();
            Integer diff = 0;
            if(last != NULL) {
                diff = Integer.valueOf((now.getTime() - last.getTime()) / (1000 * 60));
            }
            StatsTimeSinceLastUpdate = diff + ' minuto' + (diff != 1 ? 's' : '');
            dotColor = '#40b599';
            surveystatus = 'ACTIVA';
            if (diff > 60) {
                Integer temp = diff;
                diff = diff / 60;
                Integer mins = temp - (diff * 60);
                StatsTimeSinceLastUpdate = diff + ' hora' + (diff != 1 ? 's' : '');
                StatsTimeSinceLastUpdate += ' ' + mins + ' minuto' + (mins != 1 ? 's' : '');
                if (diff > 24) {
                    dotColor = 'red';
                    surveystatus = 'INACTIVA';
                    temp = diff;
                    diff = diff / 24;
                    Integer horas = temp - (diff * 24);
                    StatsTimeSinceLastUpdate = diff + ' día'  + (diff != 1 ? 's' : '');
                    StatsTimeSinceLastUpdate += ' ' + horas + ' hora' + (horas != 1 ? 's' : '');
                }
            }
            
            ListaDeDatosEncuestas = retrieveSurvey(survey_id);        
        }
    }
    
    @RemoteAction
    public static RemotingMessageHelper.DistanceChartResult retrieveDistanceData(String strSurveyId, String strType, String[] arrItems,Boolean boolCuitificados) {
        RemotingMessageHelper.DistanceChartResult objResult = null;

        System.debug('retrieveDistances ->');
        if(strType == 'questions') {
            objResult = retrieveDistancesQuestions(strSurveyId, arrItems, boolCuitificados);
        } else if (strType == 'answers') {
            objResult = retrieveDistancesAnswers(strSurveyId, arrItems, boolCuitificados);
        }
        
        System.debug('retrieveDistances <-');
        return objResult;
    }

    private static RemotingMessageHelper.DistanceChartResult retrieveDistancesQuestions(String strSurveyId, String[] arrItems,Boolean boolCuitificados) {
        RemotingMessageHelper.DistanceChartResult objResult = null;
                
        return objResult;
    }


    private static RemotingMessageHelper.DistanceChartResult retrieveDistancesAnswers(String strSurveyId, List<Id> arrItems,Boolean boolCuitificados) {
        List<Id> lstFanPage = null;
        Map<Id, List<Integer>> mapOptionLikes = null;
        List<Integer> lstLikesPerOption = null;
        RemotingMessageHelper.DistanceChartResult objResult = null;
        List<Decimal> lstRates = null;            
        Decimal dblRate = null;


        lstFanPage = retrieveTopFanPages(100, strSurveyId, boolCuitificados);
        mapOptionLikes = new Map<Id, List<Integer>>();
        objResult = new RemotingMessageHelper.DistanceChartResult();

        for(Integer intIndex = 0; intIndex < arrItems.size(); intIndex++) {
            lstLikesPerOption = retrieveLikesPerOption(strSurveyId, arrItems[intIndex], lstFanPage, boolCuitificados);
            mapOptionLikes.put(arrItems[intIndex], lstLikesPerOption);
        }

        objResult.labelX = retrieveLabels(arrItems);
        objResult.labelY = retrieveLabels(arrItems);

        for(Integer intIndex = 0; intIndex < arrItems.size(); intIndex++) {
            lstRates = new List<Decimal>();
            for(Integer intIndex2 = intIndex; intIndex2 < arrItems.size(); intIndex2++) {
                dblRate = calculateRatio(mapOptionLikes.get(arrItems[intIndex]), mapOptionLikes.get(arrItems[intIndex2]));

                lstRates.add(dblRate);
            }

            objResult.values.add(lstRates);
        }

        return objResult;
    }
    private static List<String> retrieveLabels(List<Id> lstOptions) { 
        List<String> lstLabels = null;
        List<Survey_Available_Option__c> lstSurveyOptions = null; 
        System.debug('retrieveLabels [ lstOptions : ' + lstOptions + '] ->');

        lstLabels = new List<String>();

        if(lstOptions != NULL && !lstOptions.isEmpty()) {
            lstSurveyOptions = [SELECT Id, Survey_Option__c 
                                FROM Survey_Available_Option__c 
                                WHERE Id IN :lstOptions]; 

            for(Survey_Available_Option__c objOption : lstSurveyOptions) {
                lstLabels.add(objOption.Survey_Option__c);
            }
        }

        System.debug('retrieveLabels [' + lstLabels + '] <-');
        return lstLabels;
    }

    private static Decimal calculateRatio(List<Integer> lstLikes1, List<Integer> lstLikes2) {
        List<Decimal> lstNormalizeLike1 = null;
        List<Decimal> lstNormalizeLike2 = null;
        List<Decimal> lstAverage = null;
        Decimal dblKL = null;
        Decimal dblRatio = null;

        System.debug('calculateRate [lstLikes1 : ' + lstLikes1 + ' - lstLikes2 : ' + lstLikes2 + '] ->');

        lstNormalizeLike1 = normalizeList(lstLikes1);
        lstNormalizeLike2 = normalizeList(lstLikes2);

        dblKL = calculateKL(lstNormalizeLike1, lstNormalizeLike2);
        lstAverage = retrieveAverage(lstNormalizeLike1, lstNormalizeLike2);

        dblRatio = calculateRatio(lstNormalizeLike1, lstNormalizeLike2, lstAverage, dblKL);
        System.debug('calculateRate [' + dblRatio + '] <-');
        return dblRatio;
    }

    private static Decimal calculateRatio(List<Decimal> lstNormalizeLike1, List<Decimal> lstNormalizeLike2,List<Decimal> lstAverage, Decimal dblKL) {
        Decimal dblRatio = null;
        System.debug('calculateRate [lstNormalizeLike1 : ' + lstNormalizeLike1 + ' - lstNormalizeLike2 : ' + lstNormalizeLike2 + ' - lstAverage : ' + lstAverage + ' - dblKL : ' + dblKL + ' ] ->');
        
        dblRatio = 0;
        if(lstNormalizeLike1 != NULL && lstNormalizeLike2 != NULL && lstAverage != NULL  && dblKL != NULL && lstNormalizeLike1.size() == lstNormalizeLike2.size() && lstNormalizeLike1.size() == lstAverage.size() ) {
            for(Integer intIndex = 0; intIndex < lstNormalizeLike1.size(); intIndex++) {
                dblRatio += 0.5 * dblKL * lstNormalizeLike1[intIndex] / lstAverage[intIndex] + 0.5 * dblKL * lstNormalizeLike2[intIndex] / lstAverage[intIndex];
            }
        }

        System.debug('calculateRate [' + dblRatio + '] <-');
        return dblRatio;
    }
 
    private static Decimal calculateKL(List<Decimal> lstNormalizeLike1, List<Decimal> lstNormalizeLike2) {
        Decimal dblKL = null;

        System.debug('calculateKL [lstNormalizeLike1 : ' + lstNormalizeLike1 + ' - lstNormalizeLike2 : ' + lstNormalizeLike2 + '] ->');

        if(lstNormalizeLike1 != NULL && lstNormalizeLike2 != NULL && lstNormalizeLike1.size() == lstNormalizeLike2.size()) {
            dblKL = 0;
            for(Integer intIndex = 0; intIndex < lstNormalizeLike1.size(); intIndex++) {
                dblKL += lstNormalizeLike1[intIndex] * Math.log( (lstNormalizeLike1[intIndex] / lstNormalizeLike2[intIndex]) );
            }       
        } else {
            dblKL = 0;
            System.debug('No se puede calcular el KL porque los parametros no son validos');
        }
        System.debug('calculateKL [' + dblKL + '] <-');

        return dblKL;
    }

    private static List<Decimal> retrieveAverage(List<Decimal> lstNormalizeLike1, List<Decimal> lstNormalizeLike2) { 
        List<Decimal> lstAverage = null;
        System.debug('retrieveAverage [lstNormalizeLike1 : ' + lstNormalizeLike1 + '- lstNormalizeLike2 : ' + lstNormalizeLike2 + '] ->');
        
        lstAverage = new List<Decimal>();
        for(Integer intIndex = 0; intIndex < lstNormalizeLike1.size(); intIndex++) {
            lstAverage.add( (lstNormalizeLike1[intIndex] + lstNormalizeLike2[intIndex])  / 2.0 );
        }
        
        System.debug('retrieveAverage [' + lstAverage + '] <-');
        return lstAverage;
    }

    private static List<Decimal> normalizeList(List<Integer> lstLikes) {
        List<Decimal> lstNormalizeLike = null;
        Integer intSum = null;

        System.debug('normalizeList [lstLikes : ' + lstLikes + '] ->');

        lstNormalizeLike = new List<Decimal>(); 
        intSum = 0;
        for(Integer intValue : lstLikes) {
            intSum += intValue;
        }

        for(Integer intValue : lstLikes) {
            lstNormalizeLike.add( Decimal.valueOf(intValue) / Decimal.valueOf(intSum) );
        }

        System.debug('normalizeList [' + lstNormalizeLike + '] <-');

        return lstNormalizeLike;
    }

    private static List<Integer> retrieveLikesPerOption(String strSurveyId, Id objOptionId, List<Id> lstFanPages,Boolean boolCuitificados) {
        List<User_Survey__c> lstUserSurveys = null;
        List<AggregateResult> lstFacebookLikes = null;
        Map<Id, Integer> mapLikesPerOption = null;
        List<Integer> lstLikesPerOption = null;

        System.debug('retrieveLikesPerOption [strSurveyId : ' + strSurveyId + ' - objOptionId : ' + objOptionId + ' - lstFanPages : ' + lstFanPages + ' - boolCuitificados : ' + boolCuitificados + '] ->');

        lstUserSurveys = retrieveUserSurveys(strSurveyId, (new Id[] {objOptionId}), boolCuitificados);
        mapLikesPerOption = new Map<Id, Integer>();
        lstLikesPerOption = new List<Integer>();

        lstFacebookLikes = [SELECT Facebook_Page__c, COUNT(Facebook_User__c) Cant
                            FROM Facebook_Like__c
                            WHERE Facebook_Page__c IN :lstFanPages
                            GROUP BY Facebook_Page__c];


        for(AggregateResult objFacebookPage : lstFacebookLikes) {
            mapLikesPerOption.put((Id)objFacebookPage.get('Facebook_Page__c'),(Integer) objFacebookPage.get('Cant') );
        }  

        for(Id objFacebookPageId : lstFanPages) {
            if(mapLikesPerOption.containsKey(objFacebookPageId)) {
                lstLikesPerOption.add(mapLikesPerOption.get(objFacebookPageId));
            } else {
                lstLikesPerOption.add(0);
            }
        }

        System.debug('retrieveLikesPerOption [' + lstLikesPerOption + '] <-');

        return lstLikesPerOption;
    }


    public static List<Id> retrieveTopFanPages(Integer intLimit, String strSurveyId, Boolean boolCuitificados) {
        List<Id> lstFanPage = null;
        List<User_Survey__c> lstUserSurveys = null;
	    List<AggregateResult> lstFacebookLikes = null;
        List<Id> listFacebookPageId = null;
        Set<Id> setLeadId = null;

        System.debug('retrieveTopFanPages [intLimit : ' + intLimit + ' - strSurveyId : ' + strSurveyId + ' - boolCuitificados : ' + boolCuitificados + '] ->');

        lstFacebookLikes = new List<AggregateResult>();
        lstUserSurveys = new List<User_Survey__c>();
                
        lstUserSurveys = retrieveUserSurveys(strSurveyId, NULL, boolCuitificados);
        lstFanPage = new List<Id>();

        if(lstUserSurveys != NULL && !lstUserSurveys.isEmpty()) {            
            setLeadId = new Set<Id>();
            for(User_Survey__c objUserSurvey : lstUserSurveys) {
                setLeadId.add(objUserSurvey.Lead__c);
            }

            lstFacebookLikes = [SELECT Facebook_Page__c, COUNT(Facebook_User__c) Cant
                                FROM Facebook_Like__c
                                WHERE Facebook_User__c IN :setLeadId
                                GROUP BY Facebook_Page__c
                                ORDER BY  COUNT(Facebook_User__c) DESC
                                LIMIT :intLimit ];

            for(AggregateResult objFacebookPage : lstFacebookLikes) {
                lstFanPage.add((Id)objFacebookPage.get('Facebook_Page__c'));
            }
        }
                
        System.debug('retrieveTopFanPages [' + lstFanPage + '] <-');

        return lstFanPage;
    }

    @RemoteAction
    public static  List<datos_encuesta> retrieveSurveyInfo(String strSurveyId, Boolean boolOnlyCuitificados) { 
    	List<Survey_Question__c> lstSurveyQuestions = null;
        List<AggregateResult> lstSurveysAnswers = null;
        Map<Id, datos_encuesta.opciones> mapPulsoAnswer = null;
        List<datos_encuesta> lstQuestions = null;
        datos_encuesta objQuestion = null;
        datos_encuesta.opciones objOption = null;
        Integer intQuestionIndex = null;
        Integer intOptionIndex = null;
		System.debug('retrieveSurveyInfo [strSurveyId : ' + strSurveyId + ' - boolOnlyCuitificados : ' + boolOnlyCuitificados + '] ->');        

        lstQuestions = new List<datos_encuesta>();
        
        if(String.IsNotBlank(strSurveyId)) {            
            lstSurveyQuestions = retrieveSurveyQuestions(strSurveyId);
            System.debug('retrieveSurveyInfo [lstSurveyQuestions]');        

            if(!lstSurveyQuestions.IsEmpty()) {
                lstSurveysAnswers = retrieveSurveyAnswers(strSurveyId, boolOnlyCuitificados);
                System.debug('retrieveSurveyInfo [lstSurveysAnswers]');        

                mapPulsoAnswer = createPulsoAnswerMap(lstSurveysAnswers);
                System.debug('retrieveSurveyInfo [mapPulsoAnswer]');        

                intQuestionIndex = 1;
                for (Survey_Question__c objQuestionC : lstSurveyQuestions) {
                    objQuestion = new datos_encuesta();                        
                    objQuestion.nro_pregunta = intQuestionIndex;
                    objQuestion.titulo = objQuestionC.Title__c;
                    objQuestion.lista_opciones = new List <datos_encuesta.opciones>();
                    objQuestion.suma_respuestas = 0;
                    objQuestion.suma_respuestas_cuitificadas = 0;
                    intQuestionIndex++;
                    
                    intOptionIndex = 1;
                    for (Survey_Available_Option__c objOptionC : objQuestionC.Survey_Available_Options__r) {
                        if(mapPulsoAnswer.containsKey(objOptionC.Id)) {
                            objOption = mapPulsoAnswer.get(objOptionC.Id);
                        } else {
                            objOption = new datos_encuesta.opciones();                                
                            objOption.respuestas = 0;
                            objOption.respuestas_cuitificadas = 0;
                        }
                        
                        if(boolOnlyCuitificados) {
                            objOption.respuestas = objOption.respuestas_cuitificadas;
                        }
                        
                        objOption.nro_opcion = intOptionIndex;
                        objOption.opcionid = objOptionC.Id;                            
                        objOption.pregunta = objOptionC.Survey_Option__c;
                        intOptionIndex++;
                        
                        objQuestion.lista_opciones.add(objOption);        
                        objQuestion.suma_respuestas += objOption.respuestas;                            
                        
                        objQuestion.suma_respuestas_cuitificadas += objOption.respuestas_cuitificadas;
                    }
                    System.debug('retrieveSurveyInfo [fin iteracion 1]');   
                    if (objQuestion.suma_respuestas > 0 && objQuestion.lista_opciones != NULL && objQuestion.lista_opciones.size() > 0 ) {
                        for (datos_encuesta.opciones objOptionSuma : objQuestion.lista_opciones) {
                            objOptionSuma.porcentaje = (objOptionSuma.respuestas * 100  / objQuestion.suma_respuestas);
                        }
                    } else {
                        for (datos_encuesta.opciones objOptionSumaZero : objQuestion.lista_opciones) {
                            objOptionSumaZero.porcentaje = 0;
                        }
                    }
                    System.debug('retrieveSurveyInfo [calculo porcentaje]');                
                    lstQuestions.add(objQuestion);
                }                                        
                System.debug('retrieveSurveyInfo [iteracion 2]');
            }
        }
        
        return lstQuestions;
    }
   
    private static List<Survey_Question__c> retrieveSurveyQuestions(String strSurveyId) { 
        List<Survey_Question__c> lstSurveyQuestions = null;

        System.debug('retrieveSurveyQuestions [strSurveyId : ' + strSurveyId + '] ->');        

        if(String.isNotBlank(strSurveyId)) {        
            lstSurveyQuestions = [SELECT ID, Title__c, Order__c, (SELECT ID, Index__c, Survey_Option__c, Number_Of_Answers__c 
                                                                  FROM Survey_Available_Options__r 
                                                                  ORDER BY Number_Of_Answers__c DESC)                         
                                  FROM Survey_Question__c 
                                  WHERE Survey__c = :strSurveyId
                                  AND Survey__r.Enabled__c = TRUE
                                  ORDER By Order__c ASC];
        }
        
        System.debug('retrieveSurveyQuestions [' + lstSurveyQuestions + '] <-');        

        return lstSurveyQuestions;
    }
    
    private static List<AggregateResult> retrieveSurveyAnswers(String strSurveyId, Boolean boolOnlyCuitificados) {
        List<AggregateResult> lstSurveysAnswers = null;
        String strSOQL = null; 

		System.debug('retrieveSurveyAnswers [strSurveyId : ' + strSurveyId + ' - boolOnlyCuitificados : ' + boolOnlyCuitificados + '] ->');        
        if(String.isNotBlank(strSurveyId)) {
            strSOQL = 'SELECT  Survey_Available_Option__c, ';
            strSOQL += ' 		COUNT(User_Survey__r.Lead__c) countsurvey, ';  //los que respondieron 
            strSOQL += ' 		COUNT(User_Survey__r.Lead__r.Citizen__c) cuitificados ';  //los que respondieron y estan cuitificados
            strSOQL += ' FROM User_Survey_Answers__c ';  
            strSOQL += ' WHERE User_Survey__r.Survey__c = :strSurveyId ';
            strSOQL += ' AND User_Survey__r.Survey__r.Enabled__c = TRUE ';            
            
            if(boolOnlyCuitificados == true) {
                strSOQL += ' AND (User_Survey__r.Lead__r.Citizen__c <> NULL ) ';  
            }
            
            strSOQL += ' GROUP BY Survey_Available_Option__c ';
            strSOQL += ' ORDER BY COUNT(User_Survey__r.Lead__c) DESC ';
            
            lstSurveysAnswers = Database.query(strSOQL);
        }
        System.debug('retrieveSurveyAnswers [' + lstSurveysAnswers + '] <-');        

        return lstSurveysAnswers;
    } 
    
    private static Map<Id, datos_encuesta.opciones> createPulsoAnswerMap(List<AggregateResult> lstAnswers){
        Map<Id, datos_encuesta.opciones> mapPulsoAnswer = null;
        datos_encuesta.opciones objPulsoOption = null;
        
        System.debug('createPulsoAnswerMap [lstAnswers : ' + lstAnswers + '] ->');        
        mapPulsoAnswer = new Map<Id, datos_encuesta.opciones>();
        
        for(AggregateResult objAnswer : lstAnswers) {
            objPulsoOption = new datos_encuesta.opciones();
            objPulsoOption.opcionid = (Id)objAnswer.get('Survey_Available_Option__c');
            objPulsoOption.respuestas = (Integer)objAnswer.get('countsurvey');
            objPulsoOption.respuestas_cuitificadas = (Integer)objAnswer.get('cuitificados');

            mapPulsoAnswer.put((Id)objAnswer.get('Survey_Available_Option__c'), objPulsoOption);
        }
        
        System.debug('createPulsoAnswerMap [' + mapPulsoAnswer + '] <-');        

        return mapPulsoAnswer;
    }
    
    @RemoteAction
    public static List<Datos_Encuesta> retrieveSurvey(String survey_id) {
        List <datos_encuesta> lstSurvey = new List <datos_encuesta>();        

        List <Survey_Question__c> surveyQuestionList = NULL;
        surveyQuestionList = [SELECT ID, Title__c, (Select ID, Index__c, Survey_Option__c, Number_Of_Answers__c 
                                                    From Survey_Available_Options__r 
                                                    ORDER BY Number_Of_Answers__c DESC) 
                              FROM Survey_Question__c 
                              WHERE Survey__c = :survey_id
                              AND Survey__r.Enabled__c = TRUE
                              ORDER By Order__c ASC];
        
        if (surveyQuestionList.size() > 0) {
            integer i = 1;
            for (Survey_Question__c question : SurveyQuestionList) {
                datos_encuesta survey = new datos_encuesta();
                
                survey.nro_pregunta = i;
                survey.titulo = question.Title__c;
                survey.lista_opciones = new List <datos_encuesta.opciones>();
                survey.suma_respuestas = 0;
                
                //Corrige el título de la pregunta reemplazando los (*)
                //por tags HTML <b>
                //survey.titulo = survey.titulo.replaceFirst('[*]', '<b>' );
                //survey.titulo = survey.titulo.replaceFirst('[*]', '</b>');
               
                integer j = 1;
                for (Survey_Available_Option__c surveyOption : question.Survey_Available_Options__r) {
                    datos_encuesta.opciones opcion = new datos_encuesta.opciones();
                    opcion.opcionid = surveyOption.Id;
                    opcion.nro_opcion = j;
                    opcion.pregunta = surveyOption.Survey_Option__c;
                    opcion.respuestas = (Integer)SurveyOption.Number_Of_Answers__c;
                    opcion.porcentaje = 0;
                    survey.lista_opciones.add(opcion);
                    
                    survey.suma_respuestas += opcion.respuestas;
                    j++;
                }
                
                if (survey.suma_respuestas > 0) {
                    for (datos_encuesta.opciones opcion:survey.lista_opciones) {
                        opcion.porcentaje = 100 * opcion.respuestas / survey.suma_respuestas;
                    }
                }
                
                lstSurvey.add (survey);
                i++;
            }
	        return lstSurvey;
        }
        
        return NULL;
    }
    
    @RemoteAction
    public static void InsertarEncuesta(String encuestajson) {
        RemotingMessageHelper.Encuesta encuesta = (RemotingMessageHelper.Encuesta) JSON.deserialize(encuestajson, RemotingMessageHelper.Encuesta.Class);
        Encuesta__c encuestaC = new Encuesta__c();
        
        encuestaC.TypeformId__c = encuesta.typeformid;
        encuestaC.Default_Survey__c = (encuesta.default_survey == NULL)?false:encuesta.default_survey;
        encuestaC.TypeformResultsId__c = encuesta.resultadosid;
        encuestaC.TituloEncuesta__c = encuesta.tituloencuesta;
        encuestaC.AdvertinsingID__c = encuesta.pauta;
        encuestaC.Description__c = encuesta.descripcion;
        encuestaC.Slug__c = encuesta.slug;

		//Puede haber sólo una 'default' encuesta
		//Por lo tanto, si la encuesta actual es una encuesta 'default'
		//Todas las otras encuestas deben tener 'Default_Survey__c' = false
        if (encuesta.default_survey == true) {
            List<Encuesta__c> lst = new List<Encuesta__c>();
            lst = [Select Id
                   from Encuesta__c 
                   Where Default_Survey__c = true];
            for (Encuesta__c enc : lst) {
                enc.Default_Survey__c = false;
            }
            update lst;                
        }
        
        upsert encuestaC TypeformId__c;        
    }
    
    @RemoteAction
    public static RemotingMessageHelper.FilterFanpages retrieveFilteredFanPages(Integer intLimit, String strSurveyId, List<Id> lstSelectedOptions, Boolean boolCuitificados) {
        List<RemotingMessageHelper.FacebookPageInfo> lstFanPage = null;
        List<Facebook_Page__c> listFacebookPages = new List<Facebook_Page__c>();
        List<User_Survey__c> lstUserSurveys = null;
	    List<AggregateResult> lstFacebookLikes = null;
        List<Id> listFacebookPageId = null;
        Set<Id> setLeadId = null;
        Map<Id, Integer> mapFacebookLikeCountPercentage = null;
        Map<Id, Integer> mapFacebookLikeCount = null;
		Integer intResult = null;
        Integer intTotalUsers = null;
        RemotingMessageHelper.FacebookPageInfo objPageInfo = null;
        RemotingMessageHelper.FilterFanpages objResult = null;
        
        lstFacebookLikes = new List<AggregateResult>();
        lstUserSurveys = new List<User_Survey__c>();
        System.debug('retriveFilteredFanPages [intLimit : ' + intLimit + ' - strSurveyId : ' + strSurveyId + ' - lstSelectedOptions : ' + lstSelectedOptions + ' - boolCuitificados : ' + boolCuitificados +'] ->');
                
        lstUserSurveys = retrieveUserSurveys(strSurveyId, lstSelectedOptions, boolCuitificados);
        
        if(lstUserSurveys != NULL && !lstUserSurveys.isEmpty()) {            
            setLeadId = new Set<Id>();
            intResult = retriveNumberOfQuestions(lstSelectedOptions);
            intTotalUsers = 0;
            for(User_Survey__c objUserSurvey : lstUserSurveys) {
                if(objUserSurvey.User_Survey_Answers__r.size() == intResult) {
                    setLeadId.add(objUserSurvey.Lead__c);
                    intTotalUsers++; 
                }                
            }

            System.debug('retriveFilteredFanPages [intTotalUsers : ' + intTotalUsers + ']');
            System.debug('retriveFilteredFanPages [setLeadId : ' + setLeadId + ']');

            lstFacebookLikes = [SELECT Facebook_Page__c, COUNT(Facebook_User__c) Cant
                                FROM Facebook_Like__c
                                WHERE Facebook_User__c IN :setLeadId
                                GROUP BY Facebook_Page__c
                                ORDER BY  COUNT(Facebook_User__c) DESC
                                LIMIT :intLimit ];
        }
        System.debug('retriveFilteredFanPages [lstFacebookLikes : ' + lstFacebookLikes + ']');

        listFacebookPageId = new List<Id>();
        mapFacebookLikeCountPercentage = new Map<Id, Integer>();
        mapFacebookLikeCount = new Map<Id, Integer>();
        for(AggregateResult facebookPageId : lstFacebookLikes) {
            mapFacebookLikeCount.put((Id)facebookPageId.get('Facebook_Page__c'), (Integer)facebookPageId.get('Cant'));
            mapFacebookLikeCountPercentage.put((Id)facebookPageId.get('Facebook_Page__c'), 100 * (Integer)facebookPageId.get('Cant') / intTotalUsers);
            listFacebookPageId.add((Id)facebookPageId.get('Facebook_Page__c'));    
        }
        
        System.debug('retriveFilteredFanPages [mapFacebookLikeCount : ' + mapFacebookLikeCount + ']');

        listFacebookPages = [SELECT Id, Nombre__c, Cantidad_Usuarios__c, Descripcion__c, Logo__c, Category__c,Fan_Page_Url__c
                             FROM Facebook_Page__c
                             WHERE Id IN :listFacebookPageId
                             ];

        System.debug('retriveFilteredFanPages [listFacebookPages : ' + listFacebookPages + ']');

        lstFanPage = new List<RemotingMessageHelper.FacebookPageInfo> ();
            
        for(Facebook_Page__c objPageC : listFacebookPages) {
            objPageInfo = new RemotingMessageHelper.FacebookPageInfo(objPageC);
            if(mapFacebookLikeCountPercentage.containsKey(objPageC.Id)) {
	            objPageInfo.percentage = mapFacebookLikeCountPercentage.get(objPageC.Id);                
            } else {
                objPageInfo.percentage = 0;
            }
            
            if(mapFacebookLikeCount.containsKey(objPageC.Id)) {
	            objPageInfo.survey_count = mapFacebookLikeCount.get(objPageC.Id);                
            } else {
                objPageInfo.survey_count = 0;
            }
                        
            lstFanPage.add(objPageInfo);
        }

        System.debug('retriveFilteredFanPages [lstFanPage : ' + lstFanPage + ']');

        lstFanPage.sort();

        objResult = new RemotingMessageHelper.FilterFanpages();
        objResult.fanpages = lstFanPage;
        objResult.totalusers = intTotalUsers;
        
        System.debug('retriveFilteredFanPages [' + objResult + '] <-');

        return objResult;
    }
    
    private static Integer retriveNumberOfQuestions(List<Id> lstSelectedOptions) {
        List<AggregateResult> lstOptions = null;
        
        lstOptions = [SELECT COUNT(Id) 
                      FROM Survey_Available_Option__c 
                      WHERE ID IN :lstSelectedOptions 
                      GROUP BY Survey_Question__c];
        
        return lstOptions.size();            
    }
    
    private static List<User_Survey__c> retrieveUserSurveys(String strSurveyId, List<Id> lstSelectedOptions, Boolean boolCuitificados) {
        List<User_Survey__c> lstUserSurveys = null;

         if(lstSelectedOptions != NULL && !lstSelectedOptions.isEmpty()) {
			System.debug('Filtering.....');        
            if(boolCuitificados == TRUE) {
                lstUserSurveys = [SELECT ID, (SELECT ID 
                                              FROM User_Survey_Answers__r 
                                              WHERE Survey_Available_Option__c IN :lstSelectedOptions), Lead__c
                                  FROM User_Survey__c 
                                  WHERE Survey__c =: strSurveyId
                                  AND Lead__r.Citizen__c != NULL
                                  AND Survey__r.Enabled__c = TRUE
                                  LIMIT 50000]; 
            } else {
                lstUserSurveys = [SELECT ID, (SELECT ID 
                                              FROM User_Survey_Answers__r 
                                              WHERE Survey_Available_Option__c IN :lstSelectedOptions ), Lead__c
                                  FROM User_Survey__c 
                                  WHERE Survey__c =: strSurveyId
                                  AND Survey__r.Enabled__c = TRUE
                                  LIMIT 50000];   
            }            
         } else {
             if(boolCuitificados == TRUE) {
                 lstUserSurveys = [SELECT Lead__c
                                   FROM User_Survey__c 
                                   WHERE Survey__c =: strSurveyId
                                   AND Lead__r.Citizen__c != NULL
                                   AND Survey__r.Enabled__c = TRUE
                                   LIMIT 50000];
             } else {
                 lstUserSurveys = [SELECT Lead__c
                                   FROM User_Survey__c 
                                   WHERE Survey__c =: strSurveyId    
                                   AND Survey__r.Enabled__c = TRUE
                                   LIMIT 50000];
             }             
         }    
        return lstUserSurveys;
    }
    

    
    @RemoteAction
    public static void GenerarAudiencia (String survey, List<String> idOpciones, String dataExtension) {
        System.debug(idOpciones + ' ' + dataExtension);
        pulso_admin_generar_audiencia genAud = new pulso_admin_generar_audiencia(survey, idOpciones, dataExtension);
        Id batchId = Database.executeBatch(genAud);
    }
    */
}