public class CampMemWrapper{
    public Id CampaignId;
    public Id ContactId;
    public String BlastId;
    
    public CampMemWrapper(CampaignMember cm){
        this.CampaignId = cm.CampaignId;
        this.ContactId = cm.ContactId;
        this.BlastId = cm.Campaign.Blast_Id__c;
    }
}