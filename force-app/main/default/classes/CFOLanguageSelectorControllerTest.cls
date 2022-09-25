@isTest
private class CFOLanguageSelectorControllerTest {
	
    @testSetup
    static void setup() {
        
        Account account1 = new Account();
        account1.Name = 'Test Company';
        account1.DUNS__c = 'Test';
        insert account1;
        
        Contact contact1 = new Contact();
        contact1.LastName = 'Test Contact';
        contact1.AccountId = account1.Id;
        insert contact1;
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='CFO Lens User']; 
        
        User user1 = new User(Alias = 'tUser', 
                          Email='veronicazarza@test.com', 
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing User', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = profile1.Id, 
                          User_Type__c = 'Premium',
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='veronicazarza@test.com',
                          contactId = contact1.Id);
        insert user1;
        
    }
    
    @isTest
    static void getFlagEnableComponentTest() {
        
        Test.startTest();
        	Boolean result = CFOLanguageSelectorController.getFlagEnableComponent();
        Test.stopTest();
        
        System.assertEquals(true, result, 'Expected to get a positive result');
        
    }
    
    @isTest
    static void updateCountryLanguage() {
        
        Test.startTest();
        	CFOLanguageSelectorController.updateCountryLanguage('Canada', 'French');
        Test.stopTest();
        
        Id userId = UserInfo.getUserId();
        List<User> userList = [SELECT CFO_Preferred_Country__c, CFO_Preferred_Language__c FROM User WHERE Id = :userId];
        
        System.assertEquals('Canada', userList[0].CFO_Preferred_Country__c, 'Expected to get a false result');
        System.assertEquals('French', userList[0].CFO_Preferred_Language__c, 'Expected to get a false result');
        
    }
    
}