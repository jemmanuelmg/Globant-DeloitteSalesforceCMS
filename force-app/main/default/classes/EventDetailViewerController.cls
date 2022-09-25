public without sharing class EventDetailViewerController {

    @AuraEnabled(cacheable=true)
    public static Event__c getInfoOfEvent(String eventId) {
        
        Event__c eventInfo = [SELECT 
                              Source_Program_Event_Name__c, 
                              Event_Start_Date__c, 
                              Event_End_Date__c,
                              Event_Venue__c,
                              Story_Feedback__c,
                              (SELECT 
                               Session_Name__c,
                               Session_Feedback__c,
                               Session_Date__c,
                               Session_Start_Time__c,
                               Session_End_Time__c,
                               Session_Venue__c,
                               Speaker_Faculty_Name_1__r.Name,
                               Speaker_Faculty_Name_2__r.Name,
                               Speaker_Faculty_Name_3__r.Name,
                               Speaker_Faculty_Name_4__r.Name,
                               Speaker_Faculty_Name_5__r.Name,
                               Speaker_Faculty_Name_6__r.Name,
                               Speaker_Faculty_Name_1_Title__c,
                               Speaker_Faculty_Name_2_Title__c,
                               Speaker_Faculty_Name_3_Title__c,
                               Speaker_Faculty_Name_4_Title__c,
                               Speaker_Faculty_Name_5_Title__c,
                               Speaker_Faculty_Name_6_Title__c,
                               Session_Priority_Order__c,
                               Session_Time_Zone__c,
                               Link_To_Details__c
                               FROM Event_Sessions__r
                               WHERE Show_For_All_Attendees__c = true
                               AND Session_Date__c != NULL
                               AND Session_Start_Time__c != NULL
                               AND Session_End_Time__c != NULL
                               ORDER BY Session_Date__c ASC),
                              (SELECT 
                               Label__c,
                               Content__c,
                               Type__c
                               FROM Additional_Event_Informations__r
                               ORDER BY Type__c ASC, Order__c ASC)
                              FROM Event__c 
                              WHERE Id =: eventId
                              LIMIT 1];

        return eventInfo;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Event_Agenda__c> getBreakoutSessions(String eventId) {
        
        Id currentUserId = UserInfo.getUserId();
        List<User> userList = [SELECT ContactId FROM User WHERE Id = :currentUserId];
        List<Event_Agenda__c> breakoutSessions = new List<Event_Agenda__c>();
        
        if (!userList.isEmpty()) {
            
            User currentUser = userList[0];
            String contactId = currentUser.ContactId;
            
            if (Test.isRunningTest()) {
                Contact testContact = [SELECT Id FROM Contact LIMIT 1];
                contactId = testContact.Id;
            } 
            
            List<Role__c> roleList = [SELECT 
                                      Thursday_AM_Session_Preference_1__c,
                                      Thursday_AM_Session_Preference_2__c,
                                      Thursday_AM_Session_Preference_3__c,
                                      Thursday_PM_Session_Preference_1__c,
                                      Friday_AM_Session_Preference_1__c,
                                      Friday_AM_Session_Preference_2__c
                                      FROM Role__c 
                                      WHERE Event_Name__c = :eventId 
                                      AND Participant_Name__c = :contactId
                                      LIMIT 1];
            
            if (!roleList.isEmpty()) {
                
                Role__c userRole = roleList[0];
                List<Id> breakoutSessionIds = new List<Id>();
                
                List<Role_Extension__c> roleExtensionList = [SELECT 
                                                             Thursday_AM_Session_Preference_1__c,
                                                             Thursday_AM_Session_Preference_2__c,
                                                             Thursday_AM_Session_Preference_3__c,
                                                             AM_Session_Preference_4__c,
                                                             AM_Session_Preference_5__c,
                                                             Thursday_PM_Session_Preference_1__c,
                                                             Friday_AM_Session_Preference_1__c,
                                                             Friday_AM_Session_Preference_2__c
                                                             FROM Role_Extension__c
                                                             WHERE Role__c = :userRole.id];
                
                for (Role_Extension__c roleExtension : roleExtensionList) {
                	breakoutSessionIds.add(roleExtension.Thursday_AM_Session_Preference_1__c);
                    breakoutSessionIds.add(roleExtension.Thursday_AM_Session_Preference_2__c);
                    breakoutSessionIds.add(roleExtension.Thursday_AM_Session_Preference_3__c);
                    breakoutSessionIds.add(roleExtension.AM_Session_Preference_4__c);
                    breakoutSessionIds.add(roleExtension.AM_Session_Preference_5__c);
                    breakoutSessionIds.add(roleExtension.Thursday_PM_Session_Preference_1__c);
                    breakoutSessionIds.add(roleExtension.Friday_AM_Session_Preference_1__c);
                    breakoutSessionIds.add(roleExtension.Friday_AM_Session_Preference_2__c);
                }
                                                
                breakoutSessions = [SELECT
                                    Id,
                                    Event__c,
                                    Session_Name__c,
                                    Session_Feedback__c,
                                    Session_Date__c,
                                    Session_Start_Time__c,
                                    Session_End_Time__c,
                                    Session_Venue__c,
                                    Speaker_Faculty_Name_1__r.Name,
                                    Speaker_Faculty_Name_2__r.Name,
                                    Speaker_Faculty_Name_3__r.Name,
                                    Speaker_Faculty_Name_4__r.Name,
                                    Speaker_Faculty_Name_5__r.Name,
                                    Speaker_Faculty_Name_6__r.Name,
                                    Speaker_Faculty_Name_1_Title__c,
                                    Speaker_Faculty_Name_2_Title__c,
                                    Speaker_Faculty_Name_3_Title__c,
                                    Speaker_Faculty_Name_4_Title__c,
                                    Speaker_Faculty_Name_5_Title__c,
                                    Speaker_Faculty_Name_6_Title__c,
                                    Session_Priority_Order__c,
                                    Session_Time_Zone__c,
                                    Link_To_Details__c
                                    FROM Event_Agenda__c
                                    WHERE Id IN :breakoutSessionIds
                                    AND Session_Date__c != NULL
                                    AND Session_Start_Time__c != NULL
                                    AND Session_End_Time__c != NULL];
                
            }
        }
        
        return breakoutSessions;
        
    }
    
}