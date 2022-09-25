public class PageLayoutUsageDescriptor implements Queueable {
    
    public List<List<String>> masterLayoutList;
    public List<String> fieldList;
    public List<String> pageLayoutList;
    String objectAPIName;
    String email;
        
    public PageLayoutUsageDescriptor(String objectAPIName, List<String> pageLayoutListParam, List<String> fieldListParam, String email) {
        this.objectAPIName = checkAPINameValidity(objectAPIName);
        this.pageLayoutList = getFullyQualifiedPLNames(objectAPIName, pageLayoutListParam);
        this.fieldList = fieldListParam;
        this.email = email;
        this.masterLayoutList = separatePageLayouts(this.pageLayoutList);
        System.debug('>>> The masterLayoutList');
        System.debug(this.masterLayoutList);
    }
        
    public void execute(QueueableContext qc) {
        
        Map<String, List<String>> layoutAndFieldsMap = new Map<String, List<String>>();
        Map<String, Set<String>> layoutAndSectionMap = new Map<String, Set<String>>();
        
        for (List<String> eventLayoutList : this.masterLayoutList) {
            
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, eventLayoutList);
            
            if (!layouts.isEmpty()) {
            
                for (Integer i = 0; i < layouts.size(); i ++) {
                    
                    String currentLayoutName = eventLayoutList[i];
                    List<String> listOfFields = new List<String>();
                    Set<String> listOfSections = new Set<String>();
                    
                    Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(i);
                    for (Metadata.LayoutSection section : layoutMd.layoutSections) {
                        for (Metadata.LayoutColumn column : section.layoutColumns) {
                            if (column.layoutItems != null) {
                                for (Metadata.LayoutItem item : column.layoutItems) {
                                    listOfFields.add(String.valueOf(item.field));
                                    listOfSections.add( '(' + currentLayoutName + '-' + String.valueOf(section.label) + '-' + String.valueOf(item.field) + ')');
                                }
                            }
                        }
                    }
                    
                    layoutAndFieldsMap.put(currentLayoutName, listOfFields);
                    layoutAndSectionMap.put(currentLayoutName, listOfSections);
                    
                }
            
            }
            
        }
        
        String allCSVContent = '"Field API Name"$"Page Layouts"$"Sections" \n';
        for (String fieldName : this.fieldList) {
            
            String csvRow = '"' + fieldName + '"$"';
            
            for (String layoutName : layoutAndFieldsMap.keySet()) {
             
                List<String> fieldsOnLayout = layoutAndFieldsMap.get(layoutName);
                if (fieldsOnLayout.contains(fieldName)) {
                    csvRow += layoutName.replace(objectAPIName + '-', '') + ' / ';
                }
                                
            }
            
            csvRow += '"$"';
            Set<String> uniqueSections = new Set<String>();
            for (String layoutName : layoutAndFieldsMap.keySet()) {
                
                Set<String> sectionsOnLayout = layoutAndSectionMap.get(layoutName);
                for (String sectionAndField : sectionsOnLayout) {
                    if (sectionAndField.contains('-'+fieldName+')')) {
                        
                        // Leave only the session name from inside the string with the (object-layout-section-field string)
                        String onlySectionName = sectionAndField.replace('(', '').replace(')', '').replace(layoutName+'-', '').replace('-' + fieldName, '');
                        uniqueSections.add(onlySectionName);
                        
                    }
                }
                
            }
            
            csvRow += uniqueSections.toString().replace(', ', ' / ').replace('}', '').replace('{', '');
            allCSVContent += csvRow + '\n';
            
        }
        
        Id fileId = createCSVFile(allCSVContent);
        sendEmailAlertJobDone(email, fileId);
        
    }
    
    
    public List<List<String>> separatePageLayouts(List<String> pageLayouts) {
        
        List<List<String>> lstWrapper = new List<List<String>>();
        
         for (Integer i = 0 ; i < (pageLayouts.size() / 10) + 1 ; i++) {
             
             List<String> lstTemp = new List<String>();
             
             for (Integer j = (i * 10); (j < (i * 10) + 10) && j < pageLayouts.size() ; j++){
                 lstTemp.add(pageLayouts.get(j));
             } 
             
             lstWrapper.add(lstTemp);
             
         }
        
        return lstWrapper;
        
    }
    
    public Id createCSVFile(String csvData) {
        
        ContentVersion contentVersion = new ContentVersion();
        
        String fileTitle = 'Descriptor Export ' + String.valueOf(Datetime.now()) + ' ' + Integer.valueof(Math.random() * 10);
        contentVersion.PathOnClient = 'file.csv';
        contentVersion.Title = fileTitle;
        contentVersion.VersionData = Blob.valueOf(csvData);
        
        insert contentVersion;
        
        ContentVersion result = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = :fileTitle LIMIT 1];
        return result.ContentDocumentId;
                
    }
    
    public void sendEmailAlertJobDone(String email, Id fileId) {
        
        String urlToFile = URL.getSalesforceBaseUrl().toExternalForm() + '/' + fileId;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] { email });
        message.setSubject('Object Descriptor Export Finished');
        message.setHTMLBody('Dear ' + email + '. <br><br> The object descriptinon that you\'ve requested from Salesforce is done, please download the result as a csv file by going to the following link: <br><br> <a href="' + urlToFile + '">' + urlToFile + '</a>');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }
    
    public List<String> getFullyQualifiedPLNames(String objectAPIName, List<String> pageLayoutList) {
        
        System.debug('>>> The page layouts');
        List<String> finalLayoutList = new List<String>();
        
        for (Integer i = 0; i < pageLayoutList.size(); i ++) {
            String layoutName = objectAPIName + '-' + pageLayoutList[i];
            finalLayoutList.add(EncodingUtil.urlEncode(layoutName,'UTF-8').replace('+', ' '));
            System.debug(finalLayoutList[i]);
        }
        
        return finalLayoutList;
        
    }
    
    public String checkAPINameValidity(String objectAPIName) {
        
        String lowercaseObjAPIName = objectAPIName.toLowerCase();
        Map<String, Schema.SObjectType> sobjectsMap = Schema.getGlobalDescribe();
        
        if (!sobjectsMap.containsKey(lowercaseObjAPIName)) {
            throw new CustomDescriptorException('No SObject named ' + objectAPIName);
        }
        
        return objectAPIName;
        
    }
    
}