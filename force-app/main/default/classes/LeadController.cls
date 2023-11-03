public with sharing class LeadController {
    public static void processLeads(List<Lead> lstLeads) {
        List<RemotingMessageHelper.Subscriber> lstSubscribers = null;
        RemotingMessageHelper.Subscriber objSubscriber = null;
        String strMobilePhone = null;

        if(lstLeads != NULL && !lstLeads.isEmpty()) {
            lstSubscribers = new List<RemotingMessageHelper.Subscriber>();
            for(Lead objLead : lstLeads) {
                strMobilePhone = objLead.MobilePhone;

                if(!strMobilePhone.startsWith('549') && strMobilePhone.length() == 12 ) {
                    strMobilePhone = strMobilePhone.substring(0,2) + '9' + strMobilePhone.substring(2, strMobilePhone.length());
                } else if (strMobilePhone.length() == 10) {
                    if(strMobilePhone.startsWith('15')) {
                        strMobilePhone = '11' + strMobilePhone.substring(2, strMobilePhone.length());
                    }
                    strMobilePhone = '549' + strMobilePhone;     
                }
    
                if(String.isNotBlank(strMobilePhone) && strMobilePhone.length() >= 10) {
                    objSubscriber = new RemotingMessageHelper.Subscriber();
                    objSubscriber.MobileNumber = strMobilePhone;
                    objSubscriber.SubscriberKey = strMobilePhone;
                    
                    objSubscriber.Attributes.put('Message', String.format(Label.TodosJuntos_WhatsAppMessage, new String[] {objLead.FirstName, objLead.LastName, objLead.Email, objLead.MobilePhone }) );
					objSubscriber.Attributes.put('ImageUrl', 'https://image.socialcitizencrm.com/lib/fe4415707564057c7d1470/m/1/c330c173-4c9e-4dbd-ae26-943c463f0cab.jpeg');
                    
                    lstSubscribers.add(objSubscriber);
                }
            }

            if(!lstSubscribers.isEmpty()) {
                //WhatsAppAPI.sendCustomMessage(lstSubscribers);
                WhatsAppAPI.sendCustomImage(lstSubscribers);
            }
        }
    }
}