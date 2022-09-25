public class OrchestraAttachmentService {

    public static Id auxRecordId;
    public static Integer numberOfBatches;
    
    static {
        numberOfBatches = 0;
    }
    
    public static String getBatchQueryString() {
        
        String allIdsToDownload = getStringWithAttachmentIds();
        //String mainQuery = 'SELECT ContentType, Name FROM Attachment WHERE ParentId IN (SELECT Id FROM cms__Library_Content__c WHERE cms__Type__c IN (\'PNG\', \'JPG\', \'jpeg\', \'bmp\') AND CreatedDate >= 2019-01-01T00:00:00Z AND CreatedDate <= 2021-04-14T23:59:59Z) ORDER BY CreatedDate DESC';
        
        String mainQuery = 'SELECT ContentType, Name FROM Attachment WHERE Id IN ' + allIdsToDownload;
        return mainQuery;
        
    }
    
    public static void processOrchestraAttachmentsBatch(List<Attachment> scope) {

        auxRecordId = getIdAuxRecord();
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('content');
            gen.writeStartArray();
        
                for (Attachment currentAttachment : scope) {
                    gen.writeStartObject();
                        JSONHelper.writeStringField(gen, 'type', 'cms_image');
                        gen.writeFieldName('body');
                        gen.writeStartObject();
                            gen.writeFieldName('source');
                            gen.writeStartObject();
                                    JSONHelper.writeStringField(gen, 'ref', currentAttachment.Id + '.' + currentAttachment.Name.split('\\.')[1]);
                            gen.writeEndObject();
                            JSONHelper.writeStringField(gen, 'title', currentAttachment.Id);
                        gen.writeEndObject();
                    gen.writeEndObject();
                }
        
            gen.writeEndArray();
        gen.writeEndObject();
        
        String jsonContent = gen.getAsString();
        
        Attachment attach = new Attachment();
        attach.Name = 'ImageExportData' + numberOfBatches + '.json';
        attach.Body = Blob.valueOf(jsonContent);
        attach.ContentType= 'text/txt';
        attach.ParentID = auxRecordId;
        numberOfBatches ++;
        insert attach;
        
    }
    
    public static Id getIdAuxRecord() {
        
        Datetime currentTime = System.now();
        Account auxAccount = new Account();
        auxAccount.Name = 'Orchestra Image Export - ' + String.valueOf(currentTime);
        auxAccount.DUNS__c = 'abc';
        auxAccount.Company_Record_Status__c = 'Inactive';
        insert auxAccount;
        return auxAccount.Id;
        
    }
    
    public static String getStringWithAttachmentIds() {
        
        String allIds = '( ';
        
        List<ContentVersion> contentVersionList = [SELECT  
                                                   VersionData 
                                                   FROM ContentVersion
                                                   WHERE Title = 'Orchestra Id Reference'
                                                   AND FileExtension = 'json'
                                                   AND FileType = 'JSON'
                                                   ORDER BY CreatedDate DESC
                                                   LIMIT 1];
        
        if (!contentVersionList.isEmpty()) {
            
            allIds = '( ';
            
            ContentVersion contentVersion = contentVersionList[0];
            String rawDataStr = contentVersion.VersionData.toString();
        
            Map<String, Object> unserializedData = (Map<String, Object>)JSON.deserializeUntyped(rawDataStr);
            List<Object> attachmentEntries = (List<Object>) unserializedData.get('data');
            
            for (Object entryObject : attachmentEntries) {
                
                String entrySerialized = JSON.serialize(entryObject);
                Map<String, Object> entryAsMap = (Map<String, Object>) JSON.deserializeUntyped(entrySerialized);
                
                String attachId = String.valueOf(entryAsMap.get('AttachId'));
                allIds += '\'' + attachId + '\',';
                
            }
            
            allIds = allIds.removeEnd(',');
            allIds += ' )';
            
        }

        return allIds;
        
    }
    
}