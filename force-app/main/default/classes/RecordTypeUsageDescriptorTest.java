@isTest
public class RecordTypeUsageDescriptorTest {
    
    @testSetup
    static void testSetup() {
        
        Id recordTypeId1 = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('CFO Forums Client Participant').getRecordTypeId();
        Id recordTypeId2 = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('CFO Forums Deloitte Participant').getRecordTypeId();
        Id recordTypeId3 = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('CFO Forums External Faculty/Speaker').getRecordTypeId();
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
        insert contact1;
        
        Event__c event1 = new Event__c();
        event1.Company__c = account1.Id;
        event1.Event_Type__c = 'Lab';
        event1.RecordTypeId = recordTypeId5;
        insert event1;
        
        Role__c role1 = new Role__c();
        role1.Participant_Name__c = contact1.Id;
        role1.Company_Name__c = account1.Id;
        role1.Event_Name__c = event1.Id;
        role1.RecordTypeId = recordTypeId1;
        insert role1;
        
        Role__c role2 = new Role__c();
        role2.Participant_Name__c = contact1.Id;
        role2.Company_Name__c = account1.Id;
        role2.Event_Name__c = event1.Id;
        role2.RecordTypeId = recordTypeId2;
        insert role2;
        
        Role__c role3 = new Role__c();
        role3.Participant_Name__c = contact1.Id;
        role3.Company_Name__c = account1.Id;
        role3.Event_Name__c = event1.Id;
        role3.RecordTypeId = recordTypeId3;
        insert role3;
        
    }
    

    @isTest
    static void RecordTypeUsageDescriptorExecuteTest1() {
        
        Boolean passTest = true;
        
        Test.startTest();
            try {
                
                List<String> fieldList = new List<String>();
                List<String> recTypeList = new List<String>();
                rectypeList.add('CFO Forums Client Participant');
                rectypeList.add('CFO Forums Deloitte Participant');
                rectypeList.add('CFO Forums External Faculty/Speaker');
                fieldList.add('X4_Faces__c');
                fieldList.add('X4_Faces_Target_Time_Spent__c');
                fieldList.add('Academy_Academy_relevance__c');
                fieldList.add('Academy_Academy_success__c');
                fieldList.add('Academy_Breakout_sessions__c');
                fieldList.add('Academy_Networking__c');
                fieldList.add('Academy_Participant_Role__c');
                fieldList.add('Academy_Status__c');
                fieldList.add('Acceptance_Status__c');

                Database.executeBatch(new RecordTypeUsageDescriptor('Role__c', rectypeList, fieldList, 'test@test.com', false));
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
    @isTest
    static void RecordTypeUsageDescriptorExecuteTest2() {
        
        Boolean passTest = true;
        
        Test.startTest();
            try {
                
                List<String> fieldList = new List<String>();
                List<String> recTypeList = new List<String>();
                rectypeList.add('CFO Forums Client Participant');
                rectypeList.add('CFO Forums Deloitte Participant');
                rectypeList.add('CFO Forums External Faculty/Speaker');
                fieldList.add('X4_Faces__c');
                fieldList.add('X4_Faces_Target_Time_Spent__c');
                fieldList.add('Academy_Academy_relevance__c');
                fieldList.add('Academy_Academy_success__c');
                fieldList.add('Academy_Breakout_sessions__c');
                fieldList.add('Academy_Networking__c');
                fieldList.add('Academy_Participant_Role__c');
                fieldList.add('Academy_Status__c');
                fieldList.add('Acceptance_Status__c');

                Database.executeBatch(new RecordTypeUsageDescriptor('Role__c', rectypeList, fieldList, 'test@test.com', true));
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
    @isTest
    static void RecordTypeUsageDescriptorExecuteTest3() {
        
        Boolean passTest = true;
        
        Test.startTest();
            try {
                
                List<String> recTypeList = new List<String>();
                rectypeList.add('CFO Forums Client Participant');
                rectypeList.add('CFO Forums Deloitte Participant');
                rectypeList.add('CFO Forums External Faculty/Speaker');

                Database.executeBatch(new RecordTypeUsageDescriptor('Role__c', rectypeList, null, 'test@test.com', false));
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
    @isTest
    static void getFieldListTest1() {
        
        Boolean passTest = true;
        List<String> fieldList = new List<String>();
        List<String> recTypeList = new List<String>();
        rectypeList.add('CFO Forums Client Participant');
        rectypeList.add('CFO Forums Deloitte Participant');
        rectypeList.add('CFO Forums External Faculty/Speaker');
        fieldList.add('X4_Faces__c');
        fieldList.add('X4_Faces_Target_Time_Spent__c');
        fieldList.add('Academy_Academy_relevance__c');
        fieldList.add('Academy_Academy_success__c');
        fieldList.add('Academy_Breakout_sessions__c');
        fieldList.add('Academy_Networking__c');
        fieldList.add('Academy_Participant_Role__c');
        fieldList.add('Academy_Status__c');
        fieldList.add('Acceptance_Status__c');
        
        Test.startTest();
            try {
                RecordTypeUsageDescriptor batchObj = new RecordTypeUsageDescriptor('Role__c', rectypeList, fieldList, 'test@test.com', false);
                batchObj.getFieldList(new List<String>(), true);
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
    @isTest
    static void getFieldListTest2() {
        
        Boolean passTest = true;
        List<String> fieldList = new List<String>();
        List<String> recTypeList = new List<String>();
        rectypeList.add('CFO Forums Client Participant');
        rectypeList.add('CFO Forums Deloitte Participant');
        rectypeList.add('CFO Forums External Faculty/Speaker');
        fieldList.add('X4_Faces__c');
        fieldList.add('X4_Faces_Target_Time_Spent__c');
        fieldList.add('Academy_Academy_relevance__c');
        fieldList.add('Academy_Academy_success__c');
        fieldList.add('Academy_Breakout_sessions__c');
        fieldList.add('Academy_Networking__c');
        fieldList.add('Academy_Participant_Role__c');
        fieldList.add('Academy_Status__c');
        fieldList.add('Acceptance_Status__c');
        
        Test.startTest();
            try {
                RecordTypeUsageDescriptor batchObj = new RecordTypeUsageDescriptor('Role__c', rectypeList, fieldList, 'test@test.com', false);
                batchObj.getFieldList(new List<String>(), false);
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
    @isTest
    static void getFieldListTest3() {

        Boolean passTest = true;
        List<String> fieldList = new List<String>();
        List<String> recTypeList = new List<String>();
        rectypeList.add('CFO Forums Client Participant');
        rectypeList.add('CFO Forums Deloitte Participant');
        rectypeList.add('CFO Forums External Faculty/Speaker');
        fieldList.add('X4_Faces__c');
        fieldList.add('X4_Faces_Target_Time_Spent__c');
        fieldList.add('Academy_Academy_relevance__c');
        fieldList.add('Academy_Academy_success__c');
        fieldList.add('Academy_Breakout_sessions__c');
        fieldList.add('Academy_Networking__c');
        fieldList.add('Academy_Participant_Role__c');
        fieldList.add('Academy_Status__c');
        fieldList.add('Acceptance_Status__c');
        
        Test.startTest();
            try {
                RecordTypeUsageDescriptor batchObj = new RecordTypeUsageDescriptor('Role__c', recTypeList, fieldList, 'test@test.com', false);
                batchObj.getFieldList(null, false);
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
    @isTest
    static void getSchemaFieldMapNegativeTest() {
        
        Boolean exceptionTrown = false;
        
        Test.startTest();
            try {
                RecordTypeUsageDescriptor batchObj = new RecordTypeUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com', false);
                batchObj.getSchemaFieldMap('Not_Existing_Object_ZZZ__c');
            } catch (Exception ex) {
                exceptionTrown = true;
            }
        Test.stopTest();
            
        System.assertEquals(true, exceptionTrown, 'Expected to have an exception trown');
        
    }
    
    @isTest
    static void getSchemaFieldMapPositiveTest() {
        
        Boolean passTest = true;
        
        Test.startTest();
            try {
                RecordTypeUsageDescriptor batchObj = new RecordTypeUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com', false);
                batchObj.getSchemaFieldMap('Role__c');
            } catch (Exception ex) {
                passTest = false;
            }
        Test.stopTest();
        
        System.assertEquals(true, passTest, 'Expected to execute action without exceptions');
        
    }
    
}