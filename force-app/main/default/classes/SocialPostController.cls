public class SocialPostController {        
    @InvocableMethod
    public static void sendNotifications(List<SocialPost> lstSocialPosts) { 
        Map<Contact,List<SocialPost>>  mapContactPosts = null;
        List<Social_Media_Sends__c> lstSocialMediaSends = null;
        
        System.debug('sendNotifications [' + lstSocialPosts + '] ->');
        
        if(lstSocialPosts != null && !lstSocialPosts.isEmpty()) {        
            lstSocialMediaSends = retrieveSocialMediaSendsConfiguration();
             
            if(!lstSocialMediaSends.IsEmpty()) {   
                mapContactPosts = retrieveCitizens(lstSocialPosts);
                
                if(mapContactPosts != null && !mapContactPosts.isEmpty()) {
                    sendNotifications(mapContactPosts, lstSocialMediaSends);
                } else {
                    System.debug('sendNotifications [ mapContactPosts are blank]');                    
                }
            } else {
                System.debug('sendNotifications [ lstSocialMediaSends are blank]');
            }
        } else {
            System.debug('sendNotifications [ lstSocialPosts are blank]');
        }
        
        System.debug('sendNotifications [] <-');    
    }
    
    //TODO: ESTO SE PUEDE OBVIAR PORQUE CUANDO SE  MODIFIQUE EL APEX SCS
    private static Map<Contact,List<SocialPost>> retrieveCitizens(List<SocialPost> lstSocialPosts) {
        Set<String> setHandles = null;
        List<Contact> lstCitizens = null;
        List<List<Contact>> lstSOSLResult = null;
        Map<Contact,List<SocialPost>>  mapContactPosts = null;
        String strSearchTerm = null;
        System.debug('retrieveCitizens [lstSocialPosts : ' + lstSocialPosts + '] ->');
        
        try {
            mapContactPosts = new Map<Contact,List<SocialPost>>();
            setHandles = new Set<String>();
            for(SocialPost objSocialPost : lstSocialPosts) {
                if(String.isNotBlank(objSocialPost.Handle)) {
                    setHandles.add(objSocialPost.Handle);
                }
            }
            
            strSearchTerm = String.join(new List<String>(setHandles), ' OR ');
            lstSOSLResult = [FIND :strSearchTerm RETURNING CONTACT(FirstName, LastName, Usuario_Twitter__c, Usuario_Facebook__c, Email, MobilePhone)];
            /*
            lstCitizens = [SELECT Id, FirstName, Email, MobilePhone, Usuario_Twitter__c, Twitter_Link__c, Usuario_LinkedIn__c, LinkedIn_Link__c, Usuario_Instagram__c, Instagram_Link__c, Usuario_Facebook__c, Facebook_Link__c
                           FROM Contact 
                           WHERE Usuario_Twitter__c IN :setHandles 
                           OR Twitter_Link__c IN :setHandles 
                           OR Usuario_LinkedIn__c IN :setHandles 
                           OR LinkedIn_Link__c IN :setHandles 
                           OR Usuario_Instagram__c IN :setHandles 
                           OR Instagram_Link__c IN :setHandles 
                           OR Usuario_Facebook__c IN :setHandles 
                           OR Facebook_Link__c IN :setHandles 
                           LIMIT 1000];   */
            
            System.debug('retrieveCitizens [' + lstSOSLResult +'] <-'); 
            mapContactPosts = new Map<Contact,List<SocialPost>>();
            
            if(!lstSOSLResult.isEmpty()) {
                for(List<Contact> lstResults : lstSOSLResult) {
                    for(Contact objContact : lstResults) {                         
                        mapContactPosts.put(objContact, new List<SocialPost>());
                        
                        for(SocialPost objSocialPost : lstSocialPosts) {
                            if(objSocialPost.Handle == objContact.Usuario_Twitter__c || objSocialPost.Handle == objContact.Usuario_Facebook__c) {
                                mapContactPosts.get(objContact).add(objSocialPost);
                                System.debug('retrieveCitizens [Found : ' + objContact +'] <-'); 
                            }                        
                        }
                    }
                }
            }
        } catch(Exception Ex) {
            System.debug('retrieveCitizens [' + Ex.getMessage() + ']');
            System.debug('retrieveCitizens [' + Ex.getStackTraceString() + ']');
        }
        
        System.debug('retrieveCitizens [' + mapContactPosts +'] <-');  
        
        return mapContactPosts;                
    }
    
    private static void sendNotifications(Map<Contact,List<SocialPost>> mapContactSocialPost, List<Social_Media_Sends__c> lstSocialMediaSends) {
        MarketingCloudAPIHandler objMC = null;
        RemotingMessageHelper.MarketingCloudAccessToken objAccessToken = null;
        List<RemotingMessageHelper.Subscriber> lstSubscribersSMS = null;
        List<RemotingMessageHelper.Subscriber> lstSubscribersEmail = null;
        List<RemotingMessageHelper.Subscriber> lstSubscribersWhatsApp = null;
        RemotingMessageHelper.Subscriber objSubscriber = null;
        Set<String> setPhoneNumbers = null;
        Set<String> setEmails = null;
        String strMobilePhone = null;
        
        System.debug('sendNotifications [ mapContactSocialPost : ' + mapContactSocialPost + ' : lstSocialMediaSends : ' + lstSocialMediaSends + '] ->'); 
        if(mapContactSocialPost != null && !mapContactSocialPost.isEmpty() && lstSocialMediaSends != null && !lstSocialMediaSends.isEmpty()) {
            setPhoneNumbers = new  Set<String>();
            setEmails = new  Set<String>();
            lstSubscribersSMS = new List<RemotingMessageHelper.Subscriber>();
            lstSubscribersEmail = new List<RemotingMessageHelper.Subscriber>();
            lstSubscribersWhatsApp = new List<RemotingMessageHelper.Subscriber>();
            
            for(Contact objCitizen : mapContactSocialPost.keySet()) {
                System.debug('sendNotifications [ processing citizen : ' + objCitizen + ' ]'); 

                for(SocialPost objSocialPost : mapContactSocialPost.get(objCitizen)) {
                    System.debug('sendNotifications [ processing post : ' + objSocialPost + ' ]'); 

                    for(Social_Media_Sends__c objSocialMediaSend : lstSocialMediaSends) {
                        //chequeo el hashtag yo el source son handleados
                        strMobilePhone = objCitizen.MobilePhone;
                                     
                        System.debug('sendNotifications [Hashtag : ' + objSocialMediaSend.Social_Source__r.Name + ' : ' + objSocialPost.TopicProfileName + ' ]');
                        System.debug('sendNotifications [Hashtag : ' + objSocialMediaSend.Social_Media__r.Name + ' : ' + objSocialPost.MediaProvider + ' ]');
                        if(objSocialMediaSend.Social_Source__r.Name == objSocialPost.TopicProfileName && objSocialMediaSend.Social_Media__r.Name == objSocialPost.MediaProvider) {
                            objSubscriber = new RemotingMessageHelper.Subscriber();
                            objSubscriber.MobileNumber = strMobilePhone;
                            objSubscriber.SubscriberKey = strMobilePhone;
                            objSubscriber.Attributes.put('Nombre', objCitizen.FirstName);
                            objSubscriber.Attributes.put('Tema', objSocialPost.Content );
                            objSubscriber.Attributes.put('twitterHandle', objSocialPost.Handle );
                            
                            if(objSocialMediaSend.Social_Destination__r.Name == 'Whats App') {
                                System.debug('sendNotifications [Adding WhatsApp]');
                                if(!strMobilePhone.startsWith('549')) {
                                    strMobilePhone = strMobilePhone.substring(0,2) + '9' + strMobilePhone.substring(2, strMobilePhone.length());
                                }
                                objSubscriber.MobileNumber = strMobilePhone;
                                lstSubscribersWhatsApp.add(objSubscriber);
                            } else if(objSocialMediaSend.Social_Destination__r.Name == 'SMS') {
                                System.debug('sendNotifications [SMS]');
                                if(strMobilePhone.startsWith('549')) {
                                    strMobilePhone = strMobilePhone.substring(0,2) + strMobilePhone.substring(3, strMobilePhone.length());
                                }
                                objSubscriber.MobileNumber = strMobilePhone;
                                if(!setPhoneNumbers.contains(strMobilePhone) ) {
                                    lstSubscribersSMS.add(objSubscriber);
                                    setPhoneNumbers.add(strMobilePhone); 
                                }
                            } else if(objSocialMediaSend.Social_Destination__r.Name == 'Email') {
                                System.debug('sendNotifications [Email]');
                                lstSubscribersEmail.add(objSubscriber);
                                setEmails.add(objCitizen.Email); 
                            }                          
                        }
                    }
                }             
            } 
            
            objMC = new MarketingCloudAPIHandler();
            //objAccessToken = objMC.retrieveAccessToken();  
            
            System.debug('sendNotifications [ objAccessToken : ' + objAccessToken + ']');
            System.debug('sendNotifications [ lstSubscribersSMS : ' + lstSubscribersSMS + ']');
            System.debug('sendNotifications [ lstSubscribersWhatsApp : ' + lstSubscribersWhatsApp + ']');
            System.debug('sendNotifications [ lstSubscribersEmail : ' + lstSubscribersEmail + ']');
            
            System.debug('sendNotifications [ setEmails : ' + setEmails + ']');
            
            if(!lstSubscribersSMS.IsEmpty()) {
                //objMC.sendSMS(objAccessToken, lstSubscribersSMS );                    
            }
            
            if(!setEmails.IsEmpty()) {
                //objMC.sendEmail(objAccessToken, setEmails );                
            } 
            
            if(!lstSubscribersWhatsApp.isEmpty()) {
                System.debug('sending whats app messages');
                WhatsAppAPI.sendMessages(lstSubscribersWhatsApp);                              
            }
        } else {
            System.debug('sendNotifications [ Citizens are NULL ]');
        }
    }
    
    private static List<Social_Media_Sends__c>  retrieveSocialMediaSendsConfiguration() {
        List<Social_Media_Sends__c> lstSocialMediaSends = null;
        
        lstSocialMediaSends = [SELECT ID, Social_Destination__r.Name, Social_Media__r.Name, Social_Source__r.Name
                               FROM Social_Media_Sends__c
                               WHERE Active__c = TRUE];
        
        return lstSocialMediaSends;
    }
    
        /*
    @future(callout=true)
    private static void updateAccessToken() { 
        MarketingCloudAPIHandler objMC = null;
        
        objMC = new MarketingCloudAPIHandler();
        objMC.updateAccessToken();
    }
    
    @future(callout=true)
    private static void sendNotifications(String strJSONCitizens, String strJSONConfiguration) {
        Map<Contact,List<SocialPost>> mapContactSocialPost = null;
        List<Social_Media_Sends__c> lstSocialMediaSends = null;
        
        System.debug('sendNotifications [ strJSONCitizens : ' + strJSONCitizens + ' - strJSONConfiguration : ' + strJSONConfiguration + '] ->');
        if(String.isNotBlank(strJSONCitizens) && String.isNotBlank(strJSONConfiguration) ) {
            mapContactSocialPost = (Map<Contact,List<SocialPost>>)JSON.deserialize(strJSONCitizens, Map<Contact,List<SocialPost>>.class);
            lstSocialMediaSends = (List<Social_Media_Sends__c>)JSON.deserialize(strJSONConfiguration, List<Social_Media_Sends__c>.class);
        
            sendNotifications(mapContactSocialPost, lstSocialMediaSends);
        }
        
        System.debug('sendNotifications [] <-');
    }
*/
}