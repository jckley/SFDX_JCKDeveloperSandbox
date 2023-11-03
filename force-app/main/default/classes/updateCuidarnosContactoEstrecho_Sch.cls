global class updateCuidarnosContactoEstrecho_Sch implements Schedulable{

    public static String CRON_EXP = '0 0 4 * * ?';

    global void execute(SchedulableContext objSchedulableContext) { 
        Database.executeBatch(new updateCuidarnosContactoEstrecho_Batch(), 5);
    }

}