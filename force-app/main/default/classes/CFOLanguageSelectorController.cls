public without sharing class CFOLanguageSelectorController {

    @AuraEnabled(cacheable=true)
    public static Boolean getFlagEnableComponent() {
        
        Boolean enableAccess = false;
        Id profileId = UserInfo.getProfileId();
                
        if (String.isNotBlank(profileId)) {
            
            List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE (UserType = 'Standard' AND PermissionsAuthorApex = true) OR Name = 'CFO Lens User'];
                        
            for (Profile profile : profileList) {
                if (profileId == profile.Id) {
                    enableAccess = true;
                    break;
                }
            }
                        
        }
        
        return enableAccess;
        
    }
    
    @AuraEnabled
    public static void updateCountryLanguage(String country, String language) {
        
        User currentUser = new User();
        currentUser.Id = UserInfo.getUserId();
        currentUser.CFO_Preferred_Country__c = country;
        currentUser.CFO_Preferred_Language__c = language;
        update currentUser;
        
        //List<AuthSession> sessionList = [SELECT Id FROM AuthSession WHERE UsersId =: UserInfo.getUserId()];
        //delete sessionList;
        
    }
    
}