public without sharing class CustomRegistrationController {

    final static String ACCOUNT_NAME = 'CFO Lens Subscriber';
    final static String CONTACT_RECORD_TYPE = 'External Contact';
    final static String SOURCE_PROGRAM = 'CIOP';

    @AuraEnabled
   public static String  registerNewContact(String firstName, String lastName, String email)
    {
        try {
            
            Id accountExternalId = getAccountIdByName(ACCOUNT_NAME);
            
            Id contactExternalRecordTypeId = getRecordTypeId(CONTACT_RECORD_TYPE);
            
            
            Contact potentialNewCommunityUser = new Contact();
            
            potentialNewCommunityUser.FirstName = firstName;
            potentialNewCommunityUser.LastName = lastName;
            potentialNewCommunityUser.Email = email;
            potentialNewCommunityUser.RecordTypeId = contactExternalRecordTypeId;
            potentialNewCommunityUser.AccountId = accountExternalId;
            potentialNewCommunityUser.Source_Program__c = SOURCE_PROGRAM;
            
            insert potentialNewCommunityUser;
            
            return potentialNewCommunityUser.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Id getRecordTypeId(String name)
    {
        Id recordTypeId;

        Map<String,Id> recordTypesMap = new Map<String,Id>();

        List<RecordType> recordTypesList = [
            SELECT Id, Name
            FROM RecordType
            WHERE sObjectType = 'Contact'
        ];

        for(RecordType rt : recordTypesList)
        {
            recordTypesMap.put(rt.Name, rt.Id);
        }

        return recordTypesMap.get(name);
    }
    //Modified by Vero Zarza 2021-04-16
    public static Id getAccountIdByName(String name)
    {
        Id communityAccountId;
        
        List<Account> communityAccount = new List<Account> ([
            SELECT Id, Name 
            FROM Account
            WHERE Name =: name
            LIMIT 1
        ]);
        
        if(communityAccount.size() > 0) {
            communityAccountId =  communityAccount[0].Id;
        }
        
        return communityAccountId;
        
    }
}