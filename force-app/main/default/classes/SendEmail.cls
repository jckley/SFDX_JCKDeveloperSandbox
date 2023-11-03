public with sharing class SendEmail {
    public static void sendEmailonPullCampMembers(){
    	//get the current users email address
    	String toemail = UserInfo.getUserEmail();
    	if(!String.isBlank(toemail)){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
	        String[] toAddresses=new String[] {toemail};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Pull Campaign Members process completed succesfully');
	        mail.setPlainTextBody('Pull Campaign Members process completed succesfully!');
			
			Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);    	
    		
    	}
    }
    
    // email that goes to Trace, Brad and myself when they click push that gives us:
	//	Campaign Name, Blast ID, Campaign Link and Scheduled time	

    public static void sendEmailonPullCampMembers(String campname, String status, String blastid, String camplink, String schtime, String req, String resp ){
		String subject = status + ': Pushed Email Blast for Campaign : ' +campname + ' Blast ID : ' + blastid;
		
		String strText = status + ': Pushed Email Blast for \n\r';
		 strText += 'Campaign : ' + campname + '\n\r';
		 strText += 'Blast Id : ' + blastid + '\n\r';
		 strText += 'Campaign Link : ' + camplink + '\n\r';
		 strText += 'Scheduled Time : ' + schtime + '\n\r';
		 strText += 'Request : ' + req + '\n\r';
		 strText += 'Response : ' + resp + '\n\r';
		
		String strHTMLText = status + ': Pushed Email Blast for <br/>';
		 strHTMLText += 'Campaign : ' + campname + '<br/>';
		 strHTMLText += 'Blast Id : ' + blastid + '<br/>';
		 strHTMLText += 'Campaign Link : ' + camplink + '<br/>';
		 strHTMLText += 'Scheduled Time : ' + schtime + '<br/>';
		 strHTMLText += 'Request : ' + req + '<br/>';
		 strHTMLText += 'Response : ' + resp + '<br/>';

		  
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress limit 1];
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'trace@cfbstrategies.com','robert@cfbstrategies.com','bradbaumann@gmail.com','sanjeev.mehta@bytehash.com'};
			//String[] toAddresses = new String[] {'dev@cfbstrategies.com'};
			mail.setToAddresses(toAddresses);
			mail.setSubject(subject);
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(strHTMLText);
			mail.setPlainTextBody(strText);
			if(!Test.isRunningTest()){
				mail.setOrgWideEmailAddressId(owea.get(0).Id);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
    		
    }
    
}