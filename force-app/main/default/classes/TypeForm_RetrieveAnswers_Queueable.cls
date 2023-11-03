public with sharing class TypeForm_RetrieveAnswers_Queueable implements Queueable, Database.AllowsCallouts {
    public Integer Size {get; set;}
    public String Survey {get; set;}
    public Integer Step {get; set;}

    public TypeForm_RetrieveAnswers_Queueable(Integer intSize, String strSurvey, Integer intStep) {
        System.debug('Constructor : ' + intSize);

        this.Size = intSize;
        this.Survey = strSurvey;
        this.Step = intStep;
    }

    public void execute(QueueableContext context) {
        String strToken = null;
        String strLastHour = null;
        String strNowHour = null;

        System.debug('Size : ' + this.Size);
        strToken = TypeformAPI.retrieveToken(); 

        if(this.Step == 1) {
            strLastHour = DateTime.now().addHours(-this.Size).formatGMT('yyyy-MM-dd\'T\'HH:00:00');
            strNowHour = DateTime.now().addHours( -this.Size ).formatGMT('yyyy-MM-dd\'T\'HH:30:00');
            this.Step = 2;
        } else {
            strLastHour = DateTime.now().addHours(-this.Size).formatGMT('yyyy-MM-dd\'T\'HH:30:00');
            strNowHour = DateTime.now().addHours( (-this.Size + 1 ) ).formatGMT('yyyy-MM-dd\'T\'HH:00:00');
                            
            this.Step = 1;
            this.Size = this.Size - 1;
        }
 
        TypeformAPI.retrieveTypeformAnswers(strToken, this.Survey ,strLastHour, strNowHour);

        if(!Test.isRunningTest()) {
            if(this.Size > 0) {
                System.debug('New Size : ' + this.Size);
                System.enqueueJob(new TypeForm_RetrieveAnswers_Queueable(this.Size, this.Survey, this.Step));
            }
        }
    }
}