global class updateCuidarnosStatusDetectable_Sched implements Schedulable{

    public static String CRON_EXP = '0 0 4 * * ?';

    global void execute(SchedulableContext objSchedulableContext) { 
        Database.executeBatch(new updateCuidarnosStatusDetectable_Batch(), 20);
    }

}