public class SLDXDataCleanerBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	private SLDX_Data_Cleaner_Configuration__mdt configs;
	private List<String> storeNumbers;
	
	public SLDXDataCleanerBatch(SLDX_Data_Cleaner_Configuration__mdt configs, List<String> storeNumbers){
        this.configs = configs;
        this.storeNumbers = storeNumbers;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        //Utilize configs and storeNumbers to generate query for all records that need to be deleted
        //If storeNumbers is empty or null, just grab all stores. This means it is a scheduled run, or full refresh
    }

    public void execute(Database.BatchableContext bc, List<sObject> records){
        List<sObject> recordsToDelete;
        if(String.isNotEmpty(this.configs.Data_Cleaner_Apex_Filter__c)){
            Type filterType = Type.forname(this.configs.Data_Cleaner_Apex_Filter__c);
            SLDXDataCleanerFilterInterface filter = (SLDXDataCleanerFilterInterface) filterType.newInstance();

            //Have try catch logic here in case something went wrong with instantiating the class

            recordsToDelete = filter.filter(records);
        }else{
            recordsToDelete = records;
        }
        //Delete records, record any failures
    }

    public void finish(Database.BatchableContext bc){
        //Email every email listed in this.configs.Data_Cleaner_Notification_List__c
        //the results of the run for scheduled runs only
    }

}
