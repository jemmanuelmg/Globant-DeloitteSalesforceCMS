public without sharing class ShowEventsListController {

    @AuraEnabled
    public static List<Event__c> getAvailableEvents(String mode) {
        
        List<Event__c> resultList = new List<Event__c>(); 
        User currentUser = [SELECT User_Type__c, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                
        if (currentUser.User_Type__c == 'Premium' && String.isNotBlank(currentUser.contactId)) {
            
            Date todaysDate = Date.today();
        	if (mode == 'upcoming') {
            	
                resultList = [SELECT 
                              Id, 
                              Source_Program_Event_Name__c, 
                              Event_Start_Date__c, 
                              Event_End_Date__c,
                             (SELECT 
                              Label__c, 
                              Content__c, 
                              Type__c 
                              FROM Additional_Event_Informations__r 
                              WHERE Type__c = 'Event Banner' 
                              ORDER BY Order__c ASC)
                              FROM Event__c 
                              WHERE
                              Event_Start_Date__c >= :todaysDate
                              AND Id IN 
                             (SELECT 
                              Event_Name__c 
                              FROM Role__c 
                              WHERE 
                              Participant_Name__c = :currentUser.ContactId)];  
                
            } else if (mode == 'past') {
                
                resultList = [SELECT 
                              Id, 
                              Source_Program_Event_Name__c, 
                              Event_Start_Date__c, 
                              Event_End_Date__c,
                             (SELECT 
                              Label__c, 
                              Content__c, 
                              Type__c 
                              FROM Additional_Event_Informations__r 
                              WHERE Type__c = 'Event Banner' 
                              ORDER BY Order__c ASC)
                              FROM Event__c 
                              WHERE
                              Event_Start_Date__c < :todaysDate
                              AND Id IN 
                             (SELECT 
                              Event_Name__c 
                              FROM Role__c 
                              WHERE 
                              Participant_Name__c = :currentUser.ContactId)]; 
                
            }
            
        }
        
        return resultList;
        
    }
    
}