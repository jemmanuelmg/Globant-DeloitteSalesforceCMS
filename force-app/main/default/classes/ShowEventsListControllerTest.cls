@isTest
private class ShowEventsListControllerTest {
    
    @testSetup
    static void testSetup() {
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'CFO Lens User'];

        UserRole userRole2 = new UserRole();
        userRole2.DeveloperName = 'Test_1';
        userRole2.Name = 'Test 1';
        insert userRole2;
        
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole2.Id;
        update adminUser;
        
        System.runAs(adminUser) {
        
            Id recordTypeId1 = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('CFO Forums Client Participant').getRecordTypeId();
            Id recordTypeId4 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
            Id recordTypeId5 = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Lab').getRecordTypeId();
            Id recordTypeId6 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
            
            Account account1 = new Account();
            account1.Name = 'Test Account 1';
            account1.Source_Program__c = 'CFOP';
            account1.RecordTypeId = recordTypeId6;
            insert account1;
            
            Contact contact1 = new Contact();
            contact1.LastName = 'Test Contact 1';
            contact1.Source_Program__c = 'CFOP';
            contact1.RecordTypeId = recordTypeId4;
            contact1.AccountId = account1.Id;
            insert contact1;
            
            Event__c event1 = new Event__c();
            event1.Company__c = account1.Id;
            event1.Event_Type__c = 'Lab';
            event1.RecordTypeId = recordTypeId5;
            event1.Event_Start_Date__c = Date.newInstance(1998, 6, 28);
            event1.Event_End_Date__c = Date.newInstance(1998, 6, 30);
            event1.Source_Program_Event_Name__c = 'Event 1';
            insert event1;
            
            Role__c role1 = new Role__c();
            role1.Participant_Name__c = contact1.Id;
            role1.Company_Name__c = account1.Id;
            role1.Event_Name__c = event1.Id;
            role1.RecordTypeId = recordTypeId1;
            insert role1;
                
            User user1 = new User();
            user1.FirstName = 'Test User 1';
            user1.LastName = 'Test';
            user1.Email = 'user1@showeventlistcontrollertest.com';
            user1.UserName = 'user1@showeventlistcontrollertest.com';
            user1.User_Type__c = 'Premium';
            user1.Event_User_Target__c = 'Generic 1';
            user1.ContactId = contact1.Id;
            user1.ProfileId = profile1.Id;
            user1.EmailEncodingKey='UTF-8';
            user1.LanguageLocaleKey='en_US';
            user1.LocaleSidKey='en_US';
            user1.TimeZoneSidKey='America/Los_Angeles';
            user1.Alias = 'testu';
            insert user1;
            
        }
        
    }
    
    @isTest
    static void getAvailableEventsUpcomingTest() {
        
        User testUser = [SELECT Id FROM User WHERE UserName = 'user1@showeventlistcontrollertest.com'];
		List<Event__c> resultList = new List<Event__c>();
        
        Test.startTest();
            System.runAs(testUser) {
                resultList = ShowEventsListController.getAvailableEvents('upcoming');
            }
        Test.stopTest();
        
        System.assertEquals(0, resultList.size(), 'Expected to have  no Event records returned');
        
    }
    
    @isTest
    static void getAvailableEventsPastTest() {
        
        User testUser = [SELECT Id FROM User WHERE UserName = 'user1@showeventlistcontrollertest.com'];
		List<Event__c> resultList = new List<Event__c>();
        
        Test.startTest();
            System.runAs(testUser) {
                resultList = ShowEventsListController.getAvailableEvents('past');
            }
        Test.stopTest();
        
        System.assertEquals(1, resultList.size(), 'Expected to have 1 Event record returned');
        
    }
    
}