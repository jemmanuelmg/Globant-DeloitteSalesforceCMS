public without sharing class ArticleShareAndAddFavoriteCrontroller {

    @AuraEnabled(cacheable=true)
    public static Boolean isArticleAddedAsFavorite(String articleCode) {
        
        Boolean returnBool = false;
        
        Id userId = UserInfo.getUserId();
        List<CFO_Lens_Favorite_Article__c> articleList = [SELECT Id 
                                                          FROM CFO_Lens_Favorite_Article__c 
                                                          WHERE Article_Code__c = :articleCode 
                                                          AND User__c = :userId];
        
        if (!articleList.isEmpty()) {
            returnBool = true;
        }
        
        return returnBool;
        
    }
    
    @AuraEnabled   
    public static void insertNewFavoriteArticle(String articleCode, String articleTitle, String articleUrl) {
        
        Id userId = UserInfo.getUserId();
        CFO_Lens_Favorite_Article__c favoriteArt = new CFO_Lens_Favorite_Article__c();
        
        favoriteArt.User__c = userId;
        favoriteArt.Article_Title__c = articleTitle;
        favoriteArt.Article_URL__c = articleUrl;
        favoriteArt.Article_Code__c = articleCode;
        
        insert favoriteArt;
        
    }

	@AuraEnabled   
    public static void deleteFavoriteArticle(String articleCode) {
        
        Id userId = UserInfo.getUserId();
        List<CFO_Lens_Favorite_Article__c> articleList = [SELECT Id 
                                                          FROM CFO_Lens_Favorite_Article__c 
                                                          WHERE Article_Code__c = :articleCode 
                                                          AND User__c = :userId];
        
        if (!articleList.isEmpty()) {
            delete articleList;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getFlagEnableFavorites() {
        
        Boolean enableAccess = false;
        Id userId = UserInfo.getUserId();
        List<User> userList = [SELECT ContactId FROM User WHERE Id = :userId];
        
        if (Test.isRunningTest()) {
            userList = [SELECT ContactId FROM User WHERE LastName = 'Testing User'];
        }
        
        if (!userList.isEmpty()) {
            
            User user = userList[0];
            if (String.isNotBlank(user.ContactId)) {
                enableAccess = true;
            }
            
        }
        
        return enableAccess;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CFO_Lens_Favorite_Article__c> getAllFavoriteArticles() {
        
        Id userId = UserInfo.getUserId();
        List<CFO_Lens_Favorite_Article__c> articleList = [SELECT 
                                                          Id,
                                                          Article_Title__c,
                                                          Article_URL__c,
                                                          Article_Code__c,
                                                          CreatedDate
                                                          FROM CFO_Lens_Favorite_Article__c 
                                                          WHERE User__c = :userId
                                                          ORDER BY CreatedDate DESC];
        
        return articleList;
        
    }
    
}