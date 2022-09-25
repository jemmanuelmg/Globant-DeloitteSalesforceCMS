@isTest
public class EventDetailViewerControllerTest {

    @testSetup
    static void setup() {
        
        Date today = date.today();
        Date tomorrow = today.addDays(1);
        Date yesterday = today.addDays(-1);
        
        Account account1 = new Account();
        account1.Name = 'Test Company';
        account1.DUNS__c = 'Test';
        insert account1;
        
        Contact contact1 = new Contact();
        contact1.LastName = 'Test Contact';
        contact1.AccountId = account1.Id;
        insert contact1;
        
        Event__c event1 = new Event__c();
        event1.Source_Program__c = 'CMOP';
        event1.RecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('NextGen Academy').getRecordTypeId();
        event1.Source_Program_Event_Name__c = 'Test Event 1';
        event1.Event_Type__c = 'Academy';
        event1.Event_Start_Date__c = tomorrow;
        insert event1;
        
        Event_Agenda__c session1 = new Event_Agenda__c();
        session1.Session_Name__c = 'Test Session 1';
        session1.Event__c = event1.Id;
        insert session1;
        
        Role__c role1 = new Role__c();
        role1.Source_Program__c = 'CMOP';
        role1.RecordTypeId = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('Academy Client Participant').getRecordTypeId();
        role1.Participant_Name__c = contact1.Id;
        role1.Event_Name__c = event1.Id;
        role1.Nominee_Registration_Date__c = system.today()+5;
        role1.Nomination_Acceptance_Email_Sent__c = system.today() +2;
        role1.Participant_Interview_Status__c = 'Interview Scheduled';
        role1.Current_Status__c = 'Registered';
        insert role1;
        
        Role_Extension__c roleExtension1 = new Role_Extension__c();
        roleExtension1.Role__c = role1.Id;
        roleExtension1.AM_Session_Preference_4__c = session1.Id;
        insert roleExtension1;
        
        
    }
    
    @isTest
    static void getInfoOfEventTest() {
        
        Event__c event = [SELECT Id FROM Event__c WHERE Source_Program_Event_Name__c = 'Test Event 1' LIMIT 1];
        
        Test.startTest();
        	Event__c result = EventDetailViewerController.getInfoOfEvent(event.Id);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Expected to receive a non-null event as result');
        
    }
    
    @isTest
    static void getBreakoutSessionsTest() {
        
        Event__c event = [SELECT Id FROM Event__c WHERE Source_Program_Event_Name__c = 'Test Event 1' LIMIT 1];
        
        Test.startTest();
        	List<Event_Agenda__c> sessions = EventDetailViewerController.getBreakoutSessions(event.Id);
        Test.stopTest();
        
        System.assertEquals(0, sessions.size(), 'Expected to receive an empty list of sessions');
        
    }
    
}