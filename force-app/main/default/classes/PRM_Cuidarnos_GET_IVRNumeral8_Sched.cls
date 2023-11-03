global class PRM_Cuidarnos_GET_IVRNumeral8_Sched implements Schedulable{

    global void execute(SchedulableContext objSchedulableContext) { 
        Database.executeBatch(new PRM_Cuidarnos_GET_IVRNumeral8_Batch(), 1);
    }

}