public class SLDXDataCleanerJob implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        List<SLDX_Data_Cleaner_Configuration__mdt> configs = [SELECT (all fields) FROM SLDX_Data_Cleaner_Configuration__mdt WHERE Is_Scheduled_Config__c = true];
        for(SLDX_Data_Cleaner_Configuration__mdt config: configs){
            //batch size TBD
            Database.executeBatch(new SLDXDataCleanerBatch(config, new List<String>()), 200);
        } 
    }   
 
}