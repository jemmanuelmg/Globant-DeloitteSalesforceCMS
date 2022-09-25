@isTest
public class PageLayoutUsageDescriptorTest {

    @testSetup
    static void setup() { 
                
        ContentVersion contentVersion1 = new ContentVersion();
        contentVersion1.Title = 'RoleLab';
        String jsonValue = '{"Layouts":[{"Layout":""},{"Layout":""},{"Layout":""},{"Layout":""},{"Layout":"Role__c-GX Lab Recipient"},{"Layout":""},{"Layout":"Role__c-Advisory Lab Recipient"},{"Layout":"Role__c-CTO Lab Recipient"},{"Layout":"Role__c-CHEXP Lab Recipient"},{"Layout":""},{"Layout":"Role__c-COO Lab Recipient"},{"Layout":"Role__c-CHRO Lab Recipient"},{"Layout":""},{"Layout":""},{"Layout":""},{"Layout":""},{"Layout":""},{"Layout":"Role__c-GX Lab Client Participant"},{"Layout":""},{"Layout":"Role__c-Advisory Lab Client Participant"},{"Layout":"Role__c-CTO Lab Client Participant"},{"Layout":"Role__c-CHEXP Lab Client Participant"},{"Layout":""},{"Layout":"Role__c-COO Lab Client Participant"},{"Layout":"Role__c-CHRO Lab Client Participant"}],"Fields":[{"Field":"X4_Faces__c"},{"Field":"X4_Faces_Target_Time_Spent__c"},{"Field":"AC_Chair_Experience__c"},{"Field":"AC_Experience__c"},{"Field":"AC_Member_Experience__c"},{"Field":"Actions_or_Comments_for_Stakeholder__c"},{"Field":"Additional_Comments__c"},{"Field":"Additional_Current_Role_s__c"},{"Field":"Additional_Job_Title_Category__c"},{"Field":"Advisory_Role__c"},{"Field":"Annual_Revenue_in_Millions__c"},{"Field":"Annual_Revenue_Time_of_Event__c"},{"Field":"Assessing_Talent__c"}]}';
        contentVersion1.versiondata = Blob.valueOf(jsonValue);
        contentVersion1.PathOnClient = 'RoleLab.json';
                        
        insert new List<ContentVersion>{contentVersion1};
            
    }
    
    @isTest
    static void PageLayoutUsageDescriptorExecuteTest() {
        
        Test.startTest();
        List<String> fieldList = new List<String>();
        List<String> layoutList = new List<String>();
        
        layoutList.add('Role__c-CFO Lab Recipient');
        layoutList.add('Role__c-CIO Lab Recipient');
        layoutList.add('Role__c-CLO Lab Recipient');
        layoutList.add('Role__c-CMO Lab Recipient');
        layoutList.add('Role__c-GX Lab Recipient');
        layoutList.add('Role__c-TheCenter Lab Recipient');
        layoutList.add('Role__c-Advisory Lab Recipient');
        layoutList.add('Role__c-CTO Lab Recipient');
        layoutList.add('Role__c-CHEXP Lab Recipient');
        layoutList.add('Role__c-CLO Lab Deloitte Participant');
        layoutList.add('Role__c-Lab Deloitte Participant');
        layoutList.add('Role__c-CMO Lab Deloitte Participant');
        layoutList.add('Role__c-CMO Lab Recipient');
        
        fieldList.add('X4_Faces__c');
        fieldList.add('X4_Faces_Target_Time_Spent__c');
        fieldList.add('AC_Chair_Experience__c');
        fieldList.add('AC_Experience__c');
        fieldList.add('AC_Member_Experience__c');
        fieldList.add('Actions_or_Comments_for_Stakeholder__c');
        fieldList.add('Additional_Comments__c');
        fieldList.add('Additional_Current_Role_s__c');
        fieldList.add('Additional_Job_Title_Category__c');

        PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', layoutList, fieldList, 'test@test.com');
        System.enqueueJob(queuableObj);
        Test.stopTest();
        
    }
        
    @isTest
    static void createCSVFileTest() {
        
        Test.startTest();
        	PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com');
        	Id fileId = queuableObj.createCSVFile('test$csv$data');
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(fileId), 'Expected to have a non-blank file id returned');
        
    }

    @isTest
    static void separatePageLayoutsTest() {
        
        List<String> layoutList = new List<String>();

        layoutList.add('Role__c-GX Lab Recipient');
        layoutList.add('Role__c-Advisory Lab Recipient');
        layoutList.add('Role__c-CTO Lab Recipient');
        layoutList.add('Role__c-CHEXP Lab Recipient');
        layoutList.add('Role__c-COO Lab Recipient');
        layoutList.add('Role__c-CHRO Lab Recipient');
        layoutList.add('Role__c-GX Lab Client Participant');
        layoutList.add('Role__c-Advisory Lab Client Participant');
        layoutList.add('Role__c-CTO Lab Client Participant');
        layoutList.add('Role__c-CHEXP Lab Client Participant');
        layoutList.add('Role__c-COO Lab Client Participant');
        layoutList.add('Role__c-CHRO Lab Client Participant');
        layoutList.add('Role__c-Advisory Lab Deloitte Participant');
        layoutList.add('Role__c-CTO Lab Deloitte Participant');
        layoutList.add('Role__c-CHEXP Lab Deloitte Participant');
        layoutList.add('Role__c-COO Lab Deloitte Participant');
        layoutList.add('Role__c-CHRO Lab Deloitte Participant');
        layoutList.add('Role__c-GX Lab Recipient');
        layoutList.add('Role__c-GX Lab Client Participant');
        layoutList.add('Role__c-CA Lab Deloitte Participant');
        layoutList.add('Role__c-Deloitte Participant_GX Non-CE Layout');
        layoutList.add('Role__c-Deloitte Participant_GX Non-CE Layout');
        layoutList.add('Role__c-GX Lab Recipient');
        layoutList.add('Role__c-Deloitte Participant_GX Non-CE Layout');
        layoutList.add('Role__c-Deloitte Participant_GX Non-CE Layout');
        layoutList.add('Role__c-GX Lab Recipient');
        layoutList.add('Role__c-Deloitte Participant_GX Non-CE Layout');
        layoutList.add('Role__c-Deloitte Participant_GX Non-CE Layout');
        
        Test.startTest();
        	PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', new List<String>(), layoutList, 'test@test.com');
        	List<List<String>> result = queuableObj.separatePageLayouts(layoutList);
        Test.stopTest();
        
        System.assertEquals(3, result.size(), 'Expected to have a list with three other lists of page layouts names inside');
        
    }
    
    @isTest
    static void sendEmailAlertJobDoneTest() {
        
        Test.startTest();
        	PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com');
        	queuableObj.sendEmailAlertJobDone('test.email@deloitte.ABC123.com', '0x0000000000000001');
        Test.stopTest();
        
    }
    
    @isTest
    static void checkAPINameValidityPositiveTest() {
        
        Boolean result = true;
		        
        Test.startTest();
        	try {
                PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com');
                queuableObj.checkAPINameValidity('Role__c');
            } catch (Exception ex) {
            	result = false;
        	}
        Test.stopTest();
        
        System.assertEquals(true, result, 'Expected to execute the method without exceptions');
        
    }
    
    @isTest
    static void checkAPINameValidityNegativeTest() {
        
        Boolean result = true;
		        
        Test.startTest();
        	try {
                PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com');
                queuableObj.checkAPINameValidity('Role_abc123__c');
            } catch (Exception ex) {
            	result = false;
        	}
        Test.stopTest();
        
        System.assertEquals(false, result, 'Expected to execute the method with exceptions');
        
    }
    
    @isTest
    static void appendObjAPINameToLayoutsTest() {
        
        List<String> pageLayouts = new List<String>();
        pageLayouts.add('Page Layout Name 1/test');
		        
        Test.startTest();
            PageLayoutUsageDescriptor queuableObj = new PageLayoutUsageDescriptor('Role__c', new List<String>(), new List<String>(), 'test@test.com');
            List<String> result = queuableObj.getFullyQualifiedPLNames('Role__c', pageLayouts);   
        Test.stopTest();
        
        String element = result[0];
        System.assertEquals(true, element.contains('Role__c-'), 'Expected to get a page layouts with the nam of object as prefix');
        System.assertEquals(true, !element.contains('+'), 'Expected to get a page layouts without + sign and spaces instead');
        
    }
    
    
    
}