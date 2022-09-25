@isTest
private class ArticleShareAndAddFavoriteControllerTest {

    @testSetup
    static void setup(){

        Profile profile1 = [SELECT Id FROM Profile WHERE Name='CFO Program User']; 
        
        Account account1 = new Account();
        account1.Name = 'Test Company';
        account1.DUNS__c = 'Test';
        insert account1;
        
        Contact contact1 = new Contact();
        contact1.LastName = 'Test Contact';
        contact1.AccountId = account1.Id;
        insert contact1;
        
        
        
        User user1 = new User(Alias = 'tUser', Email='veronicazarza@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = profile1.Id, User_Type__c = 'Premium',
                          TimeZoneSidKey='America/Los_Angeles', UserName='veronicazarza@test.com',
                          ContactId = contact1.Id);
        
        insert user1;
        
        CFO_Lens_Favorite_Article__c favoriteArt = new CFO_Lens_Favorite_Article__c();
        favoriteArt.User__c = user1.Id;
        favoriteArt.Article_Title__c = 'Test title';
        favoriteArt.Article_URL__c = 'www.testurl.com';
        favoriteArt.Article_Code__c = 'ABC000';
        
        insert favoriteArt;
        
    }
    
    @isTest
    static void isArticleAddedAsFavoriteTest() {
        
        User user = [SELECT Id FROM User WHERE UserName = 'veronicazarza@test.com'];
        Boolean result = false;
        
        Test.startTest();
            System.runAs(user) {
                result = ArticleShareAndAddFavoriteCrontroller.isArticleAddedAsFavorite('ABC000');
            }
        Test.stopTest();
        
        System.assertEquals(true, result, 'Expected a false result');
        
    }
    
    @isTest
    static void insertNewFavoriteArticleTest() {
        
        Test.startTest();
        	ArticleShareAndAddFavoriteCrontroller.insertNewFavoriteArticle('DEF111', 'Test Title', 'www.test.com');
        Test.stopTest();
        
        List<CFO_Lens_Favorite_Article__c> resultList = [SELECT Id FROM CFO_Lens_Favorite_Article__c];
        
        System.assertEquals(2, resultList.size(), 'Expected to receive two records');
        
    }
    
    @isTest
    static void deleteFavoriteArticleTest() {
        
        Test.startTest();
        	ArticleShareAndAddFavoriteCrontroller.deleteFavoriteArticle('ABC000');
        Test.stopTest();
        
        List<CFO_Lens_Favorite_Article__c> resultList = [SELECT Id FROM CFO_Lens_Favorite_Article__c];
        
        System.assertEquals(1, resultList.size(), 'Expected to receive only one record');
        
    }
    
    @isTest
    static void getFlagEnableFavoritesNegativeTest() {
        
        Test.startTest();
        	Boolean result = ArticleShareAndAddFavoriteCrontroller.getFlagEnableFavorites();
        Test.stopTest();
        
        
        System.assertEquals(false, result, 'Expected to receive a false result');
        
    }
    
    @isTest
    static void getFlagEnableFavoritesPositiveTest() {
        
        User user = [SELECT Id FROM User WHERE UserName = 'veronicazarza@test.com'];
        Boolean result = false;
        
        Test.startTest();
            System.runAs(user) { 
                result = ArticleShareAndAddFavoriteCrontroller.getFlagEnableFavorites();
            }
        Test.stopTest();
        
        
        System.assertEquals(true, result, 'Expected to receive a true result');
        
    }
    
    @isTest
    static void getAllFavoriteArticlesNegativeTest() {
        
        Test.startTest();
        	List<CFO_Lens_Favorite_Article__c> resultList = ArticleShareAndAddFavoriteCrontroller.getAllFavoriteArticles();
        Test.stopTest();
        
        
        System.assertEquals(0, resultList.size(), 'Expected to receive 0 records');
        
    }
    
    @isTest
    static void getAllFavoriteArticlesPositiveTest() {
        
        User user = [SELECT Id FROM User WHERE UserName = 'veronicazarza@test.com'];
        List<CFO_Lens_Favorite_Article__c> resultList = new List<CFO_Lens_Favorite_Article__c>();
        
        Test.startTest();
            System.runAs(user) { 
                resultList = ArticleShareAndAddFavoriteCrontroller.getAllFavoriteArticles();
            }	
        Test.stopTest();
        
        
        System.assertEquals(1, resultList.size(), 'Expected to receive one record');
        
    }
    
}