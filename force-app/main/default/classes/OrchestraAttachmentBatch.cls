global class OrchestraAttachmentBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = OrchestraAttachmentService.getBatchQueryString();
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Attachment> scope) {
        
        OrchestraAttachmentService.processOrchestraAttachmentsBatch(scope);
        
    }   
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
}