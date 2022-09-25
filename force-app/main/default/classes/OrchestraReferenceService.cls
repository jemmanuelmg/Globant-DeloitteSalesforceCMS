public class OrchestraReferenceService {

    public static void printAttachmentIdsOfArticles() {
        
        Set<String> attachmentIdSet = new Set<String>();
        Id auxRecordId = getIdAuxRecord();
        
        String attributesSubquery = '(SELECT cms__Name__c, cms__Simple_Name__c, cms__Value__c, cms__Simple_Value__c, cms__Language__r.cms__Language_Code__c FROM cms__Attributes__r)';
        String mainQuery = 'SELECT cms__Name__c, '+ attributesSubquery + ' FROM cms__Content__c WHERE CreatedDate >= 2020-01-01T00:00:00Z AND CreatedDate <= 2021-04-17T23:59:59Z AND cms__Published__c = true AND cms__Version_Number__c = 1 AND cms__Revision_Origin__c = null ORDER BY CreatedDate DESC';
        
        List<cms__Content__c> contentList = Database.query(mainQuery);
        
        for (cms__Content__c content : contentList) {
            
            Map<String, String> allBodiesMap = getAllArticleBodies(content.cms__Attributes__r);
            
            if (!allBodiesMap.isEmpty()) {
                
                cms__Attribute__c heroImgAttribute = getContentAttributeWithName('bannerImageUrl', content.cms__Attributes__r);
                cms__Attribute__c authorBioAttribute = getContentAttributeWithName('authorBio', content.cms__Attributes__r);
                cms__Attribute__c thumbnailImgAttribute = getContentAttributeWithName('thumbnailImageUrl', content.cms__Attributes__r);
                cms__Attribute__c authorImgAttribute = getContentAttributeWithName('authorImageUrl', content.cms__Attributes__r);
                
                String heroImgUrl = null;
                String authorImgUrl = null;            
                String thumbnailImgUrl = null;
                
                String heroImgId = '';
                String authorImgId = '';
                String thumbnailImgId = '';
                
                if (heroImgAttribute != null) {
                    heroImgUrl = heroImgAttribute.cms__Value__c;
                    heroImgId = getAttachmentIdFromUrl(heroImgUrl);
                }
                
                if (authorImgAttribute != null) {
                    authorImgUrl = authorImgAttribute.cms__Value__c; 
                    authorImgId = getAttachmentIdFromUrl(authorImgUrl);
                }
                
                if (thumbnailImgAttribute != null) {
                    thumbnailImgUrl = thumbnailImgAttribute.cms__Simple_Value__c;
                    thumbnailImgId = getAttachmentIdFromUrl(thumbnailImgUrl);
                }
                
                attachmentIdSet.add('00P0a00000mlQTmEAM');
                attachmentIdSet.add(heroImgId);
                attachmentIdSet.add(authorImgId);
                attachmentIdSet.add(thumbnailImgId);
                
                for (String body : allBodiesMap.values()) {
                    attachmentIdset.addAll(getAttachmentIdsOfBody(body));
                }
                
            }
        }
                
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('data');
        gen.writeStartArray();
        
        for (String attachId : attachmentIdset) {
            
            gen.writeStartObject();
                JSONHelper.writeStringField(gen, 'AttachId', attachId);
            gen.writeEndObject();
            
        }
        
        gen.writeEndArray();
        gen.writeEndObject();
        
        String jsonContent = gen.getAsString();
        
        Attachment attach = new Attachment();
        attach.Name = 'Orchestra Id Reference' + '.json';
        attach.Body = Blob.valueOf(jsonContent);
        attach.ContentType= 'text/txt';
        attach.ParentID = auxRecordId;
        insert attach;
        
    }
    
    public static Id getIdAuxRecord() {
        
        Datetime currentTime = System.now();
        Account auxAccount = new Account();
        auxAccount.Name = 'Orchestra Reference Export - ' + String.valueOf(currentTime);
        auxAccount.DUNS__c = 'abc';
        auxAccount.Company_Record_Status__c = 'Inactive';
        insert auxAccount;
        return auxAccount.Id;
        
    }
    
    public static Map<String, String> getAllArticleBodies(List<cms__Attribute__c> attributeList) {
        
        Map<String, String> allBodiesMap = new Map<String, String>();
        
        for (cms__Attribute__c attribute : attributeList) {
            
            if (attribute.cms__Simple_Name__c == 'body_0') {
                
                if (attribute.cms__Language__r.cms__Language_Code__c == 'en_US') {
                    
                    allBodiesMap.put('en_US', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'en_GB') {
                    
                    allBodiesMap.put('en_GB', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'es') {
                    
                    allBodiesMap.put('es', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'fr') {
                    
                    allBodiesMap.put('fr', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'zh_CN') {
                    
                    allBodiesMap.put('zh_CN', attribute.cms__Value__c);
                    
                }
                
            }
            
        }
        
        return allBodiesMap;
        
    }
    
    public static cms__Attribute__c getContentAttributeWithName(String simpleName, List<cms__Attribute__c> attributeList) {
        
        cms__Attribute__c returnAttribute;
        
        for (cms__Attribute__c attribute : attributeList) {
            
            if (!String.isBlank(attribute.cms__Simple_Name__c)) {
                if (attribute.cms__Simple_Name__c.equals(simpleName)) {
                    returnAttribute = attribute;
                }
            }
            
        }
        
        return returnAttribute;
        
    }
    
    public static String getAttachmentIdFromUrl(String urlFragment){
        
        List<String> splittedStr = urlFragment.split('=');
        return splittedStr[1];
        
    }
    
    public static List<String> getAttachmentIdsOfBody(String fullBody) {
        
        String pattern = 'src="/servlet/servlet.FileDownload?file=';
        List<String> extractedAttachIds = new List<String>();
        
        Integer fromIndex = 0;
        while (fromIndex != -1) {
            
            fromIndex = fullBody.indexOf(pattern, fromIndex);
            
            if (fromIndex != -1) {
                fromIndex += pattern.length();
                String extractedId = fullBody.mid(fromIndex, 18);
                extractedAttachIds.add(extractedId); 
            }
            
        }
        
        return extractedAttachIds;
        
    }
    
}