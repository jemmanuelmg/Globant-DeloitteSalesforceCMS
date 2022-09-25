public class RecordTypeUsageDescriptor implements Database.Batchable<sObject>, Database.Stateful{
    private List<String> fields;
    private List<String> recordTypeNames;
    private Map<String, Schema.SObjectField> schemaFieldMap;
    private Map<String, Integer> recordCountMap;
    private Map<String, Set<String>> fieldRecTypeMap = new Map<String, Set<String>>();
    private Map<String, String> fieldTypeMap;
    private Map<String, String> lastModMap;
    private String query;
    private String email;
    
    public RecordTypeUsageDescriptor(String SObjectNameParam, List<String> recordTypesNames, List<String> optionalFieldList, String emailToSendRepo, Boolean findMissingFields) {
        
        schemaFieldMap = getSchemaFieldMap(SObjectNameParam);
        fields = getFieldList(optionalFieldList, findMissingFields);
        fieldTypeMap = getFieldTypeMap(SObjectNameParam);
        recordCountMap = new Map<String, Integer>();
        lastModMap = new Map<String, String>();
        recordTypeNames = recordTypesNames;
        email = emailToSendRepo;
        initializeMaps();
        query = 'SELECT ' + String.join(fields, ',') + ', LastModifiedDate, RecordType.Name FROM ' + SObjectNameParam + ' WHERE RecordType.Name IN :recordTypeNames ORDER BY LastModifiedDate DESC';
        
        
    }
    
    public RecordTypeUsageDescriptor() {
        
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        
        for (SObject record :records) {
            for (String field : fields) {
                
                if (record.get(field) != null && schemaFieldMap.containsKey(field)) {
                    
                    Boolean flag = false;
                    
                    switch on (String.valueOf(schemaFieldMap.get(field).getDescribe().getType()).toLowerCase()){
                        when 'boolean' {
                            if (record.get(field) == true) {
                                flag = true;
                            }
                        }
                        when 'currency','integer','long','percent','double'{
                            if (Decimal.valueOf(String.valueOf(record.get(field))) > 0) {
                                flag = true;
                            }
                        }
                        when 'string','textArea' {
                            if (String.isNotBlank(String.valueOf(record.get(field)))) {
                                flag = true;
                            }
                        }
                        when else {
                            flag = true;
                        }
                    }
                
                    if (flag) {
                        fieldRecTypeMap.get(field).add(String.valueOf(record.getSObject('RecordType').get('Name')));
                        recordCountMap.put(field, recordCountMap.get(field) + 1);
                        if (lastModMap.get(field) == null) {
                            lastModMap.put(field, String.valueOf(record.get('LastModifiedDate')));
                        }
                    }
                }
                
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
        String csvData = '"Field API Name' + '"$"' + 'Field Label' + '"$"' + 'Field Type' + '"$"' + 'Has Data? (X=Yes)' + '"$"' + 'Amount of Records Found' + '"$"' + 'Record Types' + '"$"' + 'LastMofiedDate (From Most Recent Record Found)' + '\n';
        
        for (String field : fields) {
            if (schemaFieldMap.containsKey(field)) {
                
                Schema.DescribeFieldResult fieldMetaData = schemaFieldMap.get(field).getDescribe();
                String label = fieldMetaData.getLabel();
                String fieldType = fieldTypeMap.get(field);
                List<String> recTypeNames = new List<String>(fieldRecTypeMap.get(field));
                
                if (recordCountMap.get(field) > 0) {
                    csvData += '"' + field + '"$"' + label + '"$"' + fieldType + '"$"' + 'X' + '"$"' + recordCountMap.get(field) + '"$"' + String.join(recTypeNames, ' / ') + '"$"' + lastModMap.get(field) + '\n';
                } else {
                    csvData += '"' + field + '"$"' + label + '"$"' + fieldType + '"$"' + ' ' + '"$"' + recordCountMap.get(field) + '"$"' + String.join(recTypeNames, ' / ') + '"$"' + lastModMap.get(field) + '\n';
                }
                
            }
        }
        
        Id fileId = EventRoleCustomDescriptor.createCSVFile(csvData);
        EventRoleCustomDescriptor.sendEmailAlertJobDone(email, fileId);
        
    }
    
    public List<String> getOnlyExistingFields(List<String> optionalFieldList) {
        
        List<String> onlyExistingFields = new List<String>();
        for (String field : optionalFieldList) {
            field = field.toLowerCase();
            if (schemaFieldMap.containsKey(field)) {
                onlyExistingFields.add(field);
            }
        }
        
        return onlyExistingFields;
        
    }
    
    public List<String> getMissingfields(List<String> optionalFieldList) {
        
        List<String> allFields = new List<String>(schemaFieldMap.keySet());
        List<String> missingFields = new List<String>();
        
        for (Integer i = 0; i < optionalFieldList.size(); i ++) {
            optionalFieldList[i] = String.valueOf(optionalFieldList[i]).toLowerCase();
        }
        
        for (String fieldName : allFields) {
            if (!optionalFieldList.contains(fieldName)) {
                missingFields.add(fieldName);
            }
        }
        
        return missingFields;
        
    }
    
    public static Map<String, String> getFieldTypeMap(String objectApiName) {
        
        Map<String, String> fieldTypeMap = new Map<String, String>();
        List<FieldDefinition> roleFieldList = [SELECT QualifiedApiName, DataType FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :objectApiName];
        
        for (FieldDefinition fieldDef :  roleFieldList) {
            fieldTypeMap.put(String.valueOf(fieldDef.QualifiedApiName).toLowerCase(), fieldDef.DataType);
        }
        
        return fieldTypeMap;
        
    }
    
    public void initializeMaps() {
        
        for (String field : fields) {
            recordCountMap.put(field, 0);
            fieldRecTypeMap.put(field, new Set<String>());
            lastModMap.put(field, null);
        }
        
    }
    
    public Map<String, Schema.SObjectField> getSchemaFieldMap(String SObjectName) {
        
        String lowercaseObjAPIName = SObjectName.toLowerCase();
        Map<String, Schema.SObjectField> schemaFieldMap = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectType> sobjectsMap = Schema.getGlobalDescribe();
        
        if(!sobjectsMap.containsKey(lowercaseObjAPIName)){
            throw new CustomDescriptorException('No SObject named ' + SObjectName);
        } else {
           schemaFieldMap = sobjectsMap.get(lowercaseObjAPIName).getDescribe().fields.getMap(); 
        }
        
        return schemaFieldMap;
        
    }
    
    public List<String> getFieldList(List<String> optionalFieldList, Boolean findMissingFields) {
        
        List<String> fields = new List<String>();
        
        if (optionalFieldList != null && !findMissingFields) {
            fields = getOnlyExistingFields(optionalFieldList);
        } else if (optionalFieldList != null && findMissingFields) {
            fields = getMissingFields(optionalFieldList);
        } else {
            fields = new List<String>(schemaFieldMap.keySet());
        }
        
        if (fields.contains('lastmodifieddate')) {
            Integer index = fields.indexOf('lastmodifieddate');
            fields.remove(index);
        }
        
        return fields;
        
    }
}