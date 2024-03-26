public class SLDXDataCleanerBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	private SLDX_Data_Cleaner_Configuration__mdt configs;
	private List<String> storeIds;
    private DateTime timestamp;
	
    //timestamp not needed for scheduled runs
    public SLDXDataCleanerBatch(SLDX_Data_Cleaner_Configuration__mdt configs, List<String> storeIds){
        this.configs = configs;
        this.storeIds = storeIds;
    }

	public SLDXDataCleanerBatch(SLDX_Data_Cleaner_Configuration__mdt configs, List<String> storeIds, DateTime timestamp){
        this.configs = configs;
        this.storeIds = storeIds;
        this.timestamp = timestamp;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = this.configs.Data_Cleaner_Query__c;
        
        //no store id's means it's a scheduled run and should grab all SLDX records of given category.
        if(this.storeIds != null && !storeIds.isEmpty()){
            query += ' WHERE Store__c IN: (' + String.join(this.storeIds, ',') + ')';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> records){
        List<sObject> recordsToDelete = this.configs.Is_Scheduled_Config__c ? records : getDeletableSldxRecords(records);

        try{
            delete recordsToDelete;
        }catch(Exception e){
            //handle error
        }
    }

    private List<sObject> getDeletableSldxRecords(List<sObject> records){
        List<sObject> recordsToDelete;

        if(String.isNotEmpty(this.configs.Data_Cleaner_Apex_Filter__c)){
            Type filterType = Type.forname(this.configs.Data_Cleaner_Apex_Filter__c);
            SLDXDataCleanerFilterInterface filter = (SLDXDataCleanerFilterInterface) filterType.newInstance();

            //Have try catch logic here in case something went wrong with instantiating the class

            recordsToDelete = filter.filter(records);
        }else{
            recordsToDelete = records;
        }

        recordsToDelete = findNonSldxRecords(recordsToDelete);
        
    }

    private List<sObject> findNonSldxRecords(List<sObject> allRecords){
        List<sObject> nonSldxRecords = new List<sObject>(); 
        for(sObject record:recordsToDelete){
            //ensure that this is the correct way to check datetime equality, and there are no edge cases
            if(record.SLDX_Timestamp__c != this.timestamp){
                nonSldxRecords.add(record);
            }
        }
        return nonSldxRecords;
    }

    public void finish(Database.BatchableContext bc){
        //Email every email listed in this.configs.Data_Cleaner_Notification_List__c
        //the results of the run for scheduled runs only
    }

}
