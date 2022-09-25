global class OrchestraContentBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = OrchestraContentService.getBatchQueryString();
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<cms__Content__c> scope) {
        
        OrchestraContentService.processOrchestraContentsBatch(scope);
        
    }   
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
}