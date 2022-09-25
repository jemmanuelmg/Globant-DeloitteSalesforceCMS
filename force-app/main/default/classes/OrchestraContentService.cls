public class OrchestraContentService {
    
    public static Id auxRecordId;
    public static Integer numberOfBatches;
    public static Map<String, String> imageIdMap;
    public static Map<String, String> topicsMap;
    
    static {
        numberOfBatches = 0;
		imageIdMap = getImageIdMap();
        topicsMap = getAllTopicsMap();
    }
    
    public static String getBatchQueryString() {
        
        String attributesSubquery = '(SELECT cms__Name__c, cms__Simple_Name__c, cms__Value__c, cms__Simple_Value__c, cms__Language__r.cms__Language_Code__c FROM cms__Attributes__r)';
        String mainQuery = 'SELECT cms__Name__c, cms__Tag_Definition__r.cms__Name__c, '+ attributesSubquery + ' FROM cms__Content__c WHERE CreatedDate >= 2020-01-01T00:00:00Z AND CreatedDate <= 2021-05-14T23:59:59Z AND cms__Published__c = true AND cms__Version_Number__c = 1 AND cms__Revision_Origin__c = null ORDER BY CreatedDate DESC';
        
        
        /*String attributesSubquery = '(SELECT cms__Name__c, cms__Simple_Name__c, cms__Value__c, cms__Simple_Value__c, cms__Language__r.cms__Language_Code__c FROM cms__Attributes__r)';
        String mainQuery = 'SELECT cms__Name__c, cms__Tag_Definition__r.cms__Name__c, '+ attributesSubquery + ' FROM cms__Content__c WHERE Id IN (\'a0j0a00000KjgPyAAJ\') ORDER BY CreatedDate DESC';*/
		
        
        return mainQuery;
        
    }
    
    public static void processOrchestraContentsBatch(List<cms__Content__c> scope) {

        auxRecordId = getIdAuxRecord();
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('content');
        gen.writeStartArray();
        
        for (cms__Content__c content : scope) {
			
            Map<String, String> allBodiesMap = getAllArticleBodies(content.cms__Attributes__r);
            Map<String, String> allTitlesMap = getAllArticleTitles(content.cms__Attributes__r);
            cms__Attribute__c heroImgAttribute = getContentAttributeWithName('bannerImageUrl', content.cms__Attributes__r);
            
            if (!allBodiesMap.isEmpty() && !allTitlesMap.isEmpty() && heroImgAttribute != null) {
                
                Map<String, String> allAuthorBiosMap = getAllArticleAuthorInfo(content.cms__Attributes__r);
             
                cms__Attribute__c thumbnailImgAttribute = getContentAttributeWithName('thumbnailImageUrl', content.cms__Attributes__r);
                cms__Attribute__c authorImgAttribute = getContentAttributeWithName('authorImageUrl', content.cms__Attributes__r);
                cms__Attribute__c providerMemberFirm = getContentAttributeWithName('providerMemberFirm', content.cms__Attributes__r);
                cms__Attribute__c tagsAttribute = getTags(content.cms__Attributes__r);        
                
                String allTopicsAsString = getAllTopicsAsString(content.cms__Attributes__r);
                String providedBy = 'United States';
                
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
                
                if (providerMemberFirm != null) {
                    providedBy = providerMemberFirm.cms__Value__c;
                }

                gen.writeStartObject();
                JSONHelper.writeStringField(gen, 'type', 'Article');
                gen.writeFieldName('body');
                gen.writeStartObject();
                
                gen.writeFieldName('Hero Image');
                gen.writeStartObject();
                JSONHelper.writeStringField(gen, 'ref', imageIdMap.get(heroImgId));
                gen.writeEndObject();
                
                gen.writeFieldName('Thumbnail Image');
                gen.writeStartObject();
                JSONHelper.writeStringField(gen, 'ref', imageIdMap.get(thumbnailImgId));
                gen.writeEndObject();
                
                gen.writeFieldName('Author Image');
                gen.writeStartObject();
                JSONHelper.writeStringField(gen, 'ref', imageIdMap.get(authorImgId));
                gen.writeEndObject();
                
                JSONHelper.writeStringField(gen, 'Search Title', getSearchTitle(allTitlesMap));
                
                JSONHelper.writeStringField(gen, 'Title English', allTitlesMap.get('en_US'));
                JSONHelper.writeStringField(gen, 'Body English', allBodiesMap.get('en_US'));
                
                JSONHelper.writeStringField(gen, 'Title French', allTitlesMap.get('fr'));
                JSONHelper.writeStringField(gen, 'Body French', allBodiesMap.get('fr'));
                
                JSONHelper.writeStringField(gen, 'Title Chinese', allTitlesMap.get('zh_CN'));
                JSONHelper.writeStringField(gen, 'Body Chinese', allBodiesMap.get('zh_CN'));
                
                JSONHelper.writeStringField(gen, 'Author Info', allAuthorBiosMap.get('en_US'));
                JSONHelper.writeStringField(gen, 'Author Info French', allAuthorBiosMap.get('fr'));
                JSONHelper.writeStringField(gen, 'Author Info Chinese', allAuthorBiosMap.get('zh_CN'));
                
                JSONHelper.writeStringField(gen, 'Content Provided By', '<p>Content provided by Deloitte ' + providedBy + '<p>');
                
                JSONHelper.writeStringField(gen, 'Keywords', tagsAttribute.cms__Value__c + ' -Tags Found: ' + content.cms__Tag_Definition__r.cms__Name__c + ' - ' + allTopicsAsString);
                
                gen.writeEndObject();
                gen.writeEndObject();                
                
            } 
        }
            
        gen.writeEndArray();
        gen.writeEndObject();

        //Get the final json and upload it as attachment to download manually later
        String jsonContent = gen.getAsString();
        
        Attachment attach = new Attachment();
        attach.Name = 'ContentExportData' + numberOfBatches + '.json';
        attach.Body = Blob.valueOf(jsonContent);
        attach.ContentType= 'text/txt';
        attach.ParentID = auxRecordId;
        numberOfBatches ++;
        insert attach;
        
    }
    
    public static String getSearchTitle(Map<String, String> allTitlesMap) {
        
        String searchTitle = '';
        
        if (String.isNotBlank(allTitlesMap.get('en_US'))) {
            searchTitle += allTitlesMap.get('en_US');
        }
        
        if (String.isNotBlank(allTitlesMap.get('fr'))) {
            searchTitle += ' / ' + allTitlesMap.get('fr');
        }
        
        if (String.isNotBlank(allTitlesMap.get('es'))) {
            searchTitle += ' / ' + allTitlesMap.get('es');
        }
        
        if (String.isNotBlank(allTitlesMap.get('zh_CN'))) {
            searchTitle += ' / ' + allTitlesMap.get('zh_CN');
        }
        
        if (searchTitle.length() > 200) {
            return searchTitle.left(197) + '...';
        } else {
            return searchTitle;
        }
        
    }
    
    public static Id getIdAuxRecord() {
        
        //Create an auxiliary record to store temporary the jsons created as attachments linked to it
       	Datetime currentTime = System.now();
        Account auxAccount = new Account();
        auxAccount.Name = 'Orchestra Content Export - ' + String.valueOf(currentTime);
        auxAccount.DUNS__c = 'abc';
        auxAccount.Company_Record_Status__c = 'Inactive';
        insert auxAccount;
        return auxAccount.Id;
        
        
    }
            
    public static String getAttachmentIdFromUrl(String urlFragment){
        
        List<String> splittedStr = urlFragment.split('=');
        return splittedStr[1];
        
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
    
    public static cms__Attribute__c getTags(List<cms__Attribute__c> attributeList) {
        
        cms__Attribute__c retAttribute = new cms__Attribute__c();
        
        for (cms__Attribute__c attribute : attributeList) {
            if (attribute.cms__Simple_Name__c == 'renderTagPath' && (attribute.cms__Language__r.cms__Language_Code__c == 'en_US' || attribute.cms__Language__r.cms__Language_Code__c == 'en_GB')) {
            	retAttribute = attribute;
            }
        }
        
        return retAttribute;
        
    }
    
    public static Map<String, String> getAllArticleBodies(List<cms__Attribute__c> attributeList) {
        
        Map<String, String> allBodiesMap = new Map<String, String>();
        
        for (cms__Attribute__c attribute : attributeList) {
            
            if (attribute.cms__Simple_Name__c == 'body_0') {
                
                attribute.cms__Value__c = replaceAllIdsOfInternalImages(attribute.cms__Value__c);
                                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<p>', '<p style="line-height: 1.6 !important; font-size: 16.5px !important;">');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('</p>', '</p><br>');
                                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<div>', '<div style="line-height: 1.6 !important; font-size: 16.5px !important;>"');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<hr>', '<hr style="margin-bottom: 5px !important; margin-top: 5px !important";>');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<li>', '<li style="line-height: 1.6 !important; font-size: 16.5px !important";>');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('float:left;', '');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<figcaption>', '<div><b>');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('</figcaption>', '</b></div><br>');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<img', '<img data-orchestraelement="img" ');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<h3>', '<h3 style="font-size: 1.375em; color:#0076A8;">');
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<small>', '<small style="font-size: 12px !important;">');

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
    
    public static Map<String, String> getAllArticleAuthorInfo(List<cms__Attribute__c> attributeList) {
        
        Map<String, String> allAuthorBios = new Map<String, String>();
        
        for (cms__Attribute__c attribute : attributeList) {
            
            if (attribute.cms__Simple_Name__c == 'authorBio') {
                
                attribute.cms__Value__c = attribute.cms__Value__c.replace('<p>', '<p style="line-height: 1.6 !important; font-size: 16.5px !important;">');
                              
                if (attribute.cms__Language__r.cms__Language_Code__c == 'en_US') {
                    
                	allAuthorBios.put('en_US', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'en_GB') {
                    
                    allAuthorBios.put('en_GB', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'es') {
                    
                    allAuthorBios.put('es', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'fr') {
                    
                    allAuthorBios.put('fr', attribute.cms__Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'zh_CN') {
                    
                    allAuthorBios.put('zh_CN', attribute.cms__Value__c);
                    
                }
                
            }
            
        }
        
        return allAuthorBios;
        
    }
    
    public static Map<String, String> getAllArticleTitles(List<cms__Attribute__c> attributeList) {
        
        Map<String, String> allTitlesMap = new Map<String, String>();
        
        for (cms__Attribute__c attribute : attributeList) {
            
            if (attribute.cms__Simple_Name__c == 'title') {
                
                if (attribute.cms__Language__r.cms__Language_Code__c == 'en_US') {
                    
                	allTitlesMap.put('en_US', attribute.cms__Simple_Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'en_GB') {
                    
                    allTitlesMap.put('en_GB', attribute.cms__Simple_Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'es') {
                    
                    allTitlesMap.put('es', attribute.cms__Simple_Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'fr') {
                    
                    allTitlesMap.put('fr', attribute.cms__Simple_Value__c);
                    
                } else if (attribute.cms__Language__r.cms__Language_Code__c == 'zh_CN') {
                    
                    allTitlesMap.put('zh_CN', attribute.cms__Simple_Value__c);
                    
                }
                
            }
            
        }
        
        return allTitlesMap;
        
    }
    
    public static List<String> divideBodyIntoPieces(String fullBody, Integer piecesAmount, Integer maxCharacterAmount) {
        
        List<String> returnList = new List<String>();
        
        Integer fromCharacter = 0;
        for (Integer i = 0; i <= piecesAmount; i ++) {
            
            String stringPiece = fullBody.mid(fromCharacter, maxCharacterAmount);
            returnList.add(stringPiece);
            fromCharacter += maxCharacterAmount;
            
        }
        
        return returnList;
        
    }
    
    public static Map<String, String> getImageIdMap() {
        
        Map<String, String> resultMap = new Map<String, String>();
        
        List<ContentVersion> contentVersionList = [SELECT  
                                                   VersionData 
                                                   FROM ContentVersion
                                                   WHERE Title = 'Orchestra Id Mapping'
                                                   AND FileExtension = 'json'
                                                   AND FileType = 'JSON'
                                                   ORDER BY CreatedDate DESC
                                                   LIMIT 1];
        
        if (!contentVersionList.isEmpty()) {
            
            ContentVersion contentVersion = contentVersionList[0];
            String rawDataStr = contentVersion.VersionData.toString();
        
            Map<String, Object> unserializedData = (Map<String, Object>)JSON.deserializeUntyped(rawDataStr);
            List<Object> contentEntries = (List<Object>) unserializedData.get('data');
            
            for (Object entryObject : contentEntries) {
                
                String entrySerialized = JSON.serialize(entryObject);
                Map<String, Object> entryAsMap = (Map<String, Object>) JSON.deserializeUntyped(entrySerialized);
                
                String key = String.valueOf(entryAsMap.get('key'));
                String value = String.valueOf(entryAsMap.get('value'));
                
                resultMap.put(key, value);
                
            }
            
        }

        return resultMap;
        
    }
    
    public static String replaceAllIdsOfInternalImages(String fullBody) {
        
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
        
        for (String attachmentId : extractedAttachIds) {
                        
            String toReplace = attachmentId + '"';
            String replacement = toReplace + ' data-contentkey="'+ imageIdMap.get(attachmentId) + '" '  ;
            fullBody = fullBody.replaceAll(toReplace, replacement);
            
        }
        
        return fullBody;
        
    }
    
    public static String getAllTopicsAsString(List<cms__Attribute__c> attributeList) {
        
        String topicsAsString = '';
        
        for (cms__Attribute__c attribute : attributeList) {
            if (attribute.cms__Simple_Name__c == 'tagPathId') {
                
                if (String.isNotBlank(attribute.cms__Value__c)) {
                    topicsAsString += topicsMap.get(attribute.cms__Value__c) + ', ';
                } else {
                    topicsAsString += topicsMap.get(attribute.cms__Simple_Value__c) + ', ';
                }
                
            }
        }
        
        return topicsAsString;
        
    }
    
    public static Map<String, String> getAllTopicsMap() {
        
        List<cms__Tag_Definition__c> tagDefinitionList = [SELECT cms__Name__c FROM cms__Tag_Definition__c];
        Map<String, String> topicsMap = new Map<String, String>();
        
        for (cms__Tag_Definition__c tag : tagDefinitionList) {
            topicsMap.put(tag.Id, tag.cms__Name__c);
        }
        
        return topicsMap;
        
    }
    
}