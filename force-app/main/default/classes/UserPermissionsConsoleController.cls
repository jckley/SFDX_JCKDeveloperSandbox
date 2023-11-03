public class UserPermissionsConsoleController {
    
    public Id userId {get;set;}
    public Contact contact {get;set;}
    public User currentUser {get;set;}
    public List<GroupPermissionWrapper> permissions {get;set;}
    public List<SystemPermissionWrapper> systemPermissions {get;set;}
    public List<PermissionSet> permissionSets {get;set;}
    public List<CustomPermission> customPermissions {get;set;}
    public List<FieldPermissions> fieldPermissions;
    public String groupName {get;set;}
    public List<FieldPermissionDetailWrapper> selectedGroupDetail {get;set;}
    List<String> identificationFields = new List<String> {'Id', 'UUID__c', 'Name', 'Birthdate', 'Document_Number__c', 
            'Cuil_Number__c', 'Gender__c', 'Nacionalidad__c', 'Age_f_x__c', 'PhotoUrl_legacy__c', 'Administrative_Level_0__c', 
            'Administrative_Level_1__c', 'Administrative_Level_2__c', 'Administrative_Level_3__c', 'Administrative_Level_4__c'};
    List<String> attributeFields = new List<String> {'Movilidad__c', 'Profession__c', 'Education_Level__c', 'Ingreso__c', 
        'Beneficios_Sociales__c', 'condicion_de_ingreso__c'};
    List<String> incomeFields = new List<String> {'Employer_1__c', 'Employer_2__c', 'Employer_3__c', 'CUIT_Empleador_1__c', 'CUIT_Empleador_2__c', 
        'CUIT_Empleador_3__c', 'Sueldo_1__c', 'Sueldo_2__c', 'Sueldo_3__c',  'Income_Total__c'};
    List<String> electoralFields = new List<String> {};
    List<String> contactFields = new List<String> {'MailingAddress', 'HomePhone', 'Phone', 'Email', 'Whatsapp__c', 'Telegram__c', 'Facebook_Link__c',
        'Usuario_Facebook__c', 'Twitter_Link__c', 'Usuario_Twitter__c', 'Instagram_Link__c', 'Usuario_Instagram__c', 'Linkedin_Link__c', 'Usuario_Linkedin__c'};
    List<String> hasContactFields = new List<String> {'Tiene_Telefonos_Fijos__c', 'Tiene_Moviles__c', 'Tiene_Email__c', 'Tiene_Facebook__c',
        'Tiene_Instagram__c', 'Tiene_Linkedin__c', 'Tiene_Twitter__c', 'Whatsapp__c', 'Telegram__c', 'Socio_CARP__c'};
    List<String> tagsFields = new List<String> {'Community__c', 'Audiencia_Politica__c', 'Audiencia_Electoral__c', 'Audiencia_Generaciones__c'};
    List<String> tagsProjectFields = new List<String> {'Alerta_Buenos_Aires__c', 'Alerta_Buenos_Aires_ID__c', 
        'Alerta_Buenos_Aires_SirenaID__c', 'ADFi_Profile_ID__c'};
    List<String> systemPermissionsFieldsProfile = new List<String> {'PermissionsApiUserOnly', 'PermissionsApiEnabled', 'PermissionsApexRestServices',
        'PermissionsBulkApiHardDelete', 'PermissionsExportReport', 'PermissionsRunReports', 'PermissionsViewSetup', 'PermissionsEmailMass', 
        'PermissionsEmailSingle', 'PermissionsManageNetworks', 'PermissionsGovernNetworks', 'PermissionsManageUsers', 'PermissionsManageInternalUsers', 
        'PermissionsAssignPermissionSets', 'PermissionsViewAllData', 'PermissionsModifyMetadata', 'PermissionsModifyAllData', 'PermissionsManageIpAddresses'};
    List<String> systemPermissionsFieldsPermissionSet = new List<String> {'PermissionsAddAnalyticsRemoteConnections', 'PermissionsWaveTabularDownload',
        'PermissionsInsightsAppEltEditor', 'PermissionsInsightsAppUser', 'PermissionsCreateUpdateSDDStory', 'PermissionsCreateUpdateSDDDataset', 'PermissionsInsightsAppAdmin'};
    //Lists where field permissions are saved in groups
    public List<FieldPermissionDetailWrapper> identificationList;
    public List<FieldPermissionDetailWrapper> attributesList;
    public List<FieldPermissionDetailWrapper> incomeList;
    public List<FieldPermissionDetailWrapper> electoralList;
    public List<FieldPermissionDetailWrapper> contactList;
    public List<FieldPermissionDetailWrapper> hasContactList;
    public List<FieldPermissionDetailWrapper> tagList;
    public List<FieldPermissionDetailWrapper> tagProjectList;
            
    public UserPermissionsConsoleController () {
        contact = new Contact();
        userId = ApexPages.CurrentPage().getParameters().get('id');
        if(userId != NULL){
            contact.OwnerId = userId;
            currentUser = [SELECT Id, Name, Profile.Name, Profile.Id FROM User WHERE Id =: userId];
            permissions = getGroupPermissions(userId);
            systemPermissions = getSystemPermissions(currentUser);
            permissionSets = getPermissionSets(userId);
            customPermissions = getCustomPermissions(permissionSets);   
        }
    }
    
    public PageReference updateUserView () {
        userId = contact.OwnerId;
        if(userId != NULL){
            currentUser = [SELECT Id, Name, Profile.Name, Profile.Id FROM User WHERE Id =: userId];
            permissions = getGroupPermissions(userId);
            systemPermissions = getSystemPermissions(currentUser);
            permissionSets = getPermissionSets(userId);
            customPermissions = getCustomPermissions(permissionSets);
        }
        return null;
    }
    
    public PageReference getGroupDetail () {
        userId = ApexPages.CurrentPage().getParameters().get('id');
        groupName = ApexPages.CurrentPage().getParameters().get('group');
        selectedGroupDetail = new List<FieldPermissionDetailWrapper>();
        if(groupName == 'Identificacion'){
            selectedGroupDetail = identificationList;
            addMissingFieldsToGroup(selectedGroupDetail, identificationFields);
        }else if(groupName == 'Atributos'){
            selectedGroupDetail = attributesList;
            addMissingFieldsToGroup(selectedGroupDetail, attributeFields);
        }else if(groupName == 'Ingresos'){
            selectedGroupDetail = incomeList;
            addMissingFieldsToGroup(selectedGroupDetail, incomeFields);
        }else if(groupName == 'Electoral'){
            selectedGroupDetail = electoralList;
            addMissingFieldsToGroup(selectedGroupDetail, electoralFields);
        }else if(groupName == 'Contacto'){
            selectedGroupDetail = contactList;
            addMissingFieldsToGroup(selectedGroupDetail, contactFields);
        }else if(groupName == 'Contacto(tiene)'){
            selectedGroupDetail = hasContactList;
            addMissingFieldsToGroup(selectedGroupDetail, hasContactFields);
        }else if(groupName == 'Tags Standard'){
            selectedGroupDetail = tagList;
            addMissingFieldsToGroup(selectedGroupDetail, tagsFields);
        }else if(groupName == 'Tags x proyecto'){
            selectedGroupDetail = tagProjectList;
            addMissingFieldsToGroup(selectedGroupDetail, tagsProjectFields);
        }
        return null;
    }    
    
    public PageReference goBack() {
        
        return Page.UserPermissionsConsole;
    }
    
    public List<GroupPermissionWrapper> getGroupPermissions(Id userId) {
        
        List<GroupPermissionWrapper> permissionsList = new List<GroupPermissionWrapper>();
        fieldPermissions = [SELECT Id, PermissionsEdit, PermissionsRead, Field FROM FieldPermissions WHERE 
                            ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE Assignee.Id =: userId) AND SobjectType = 'Contact' AND (NOT Parent.Name LIKE 'X00e%')];
        //Lists where field permissions are saved in groups
        identificationList = new List<FieldPermissionDetailWrapper>();
        attributesList = new List<FieldPermissionDetailWrapper>();
        incomeList = new List<FieldPermissionDetailWrapper>();
        electoralList = new List<FieldPermissionDetailWrapper>();
        contactList = new List<FieldPermissionDetailWrapper>();
        hasContactList = new List<FieldPermissionDetailWrapper>();
        tagList = new List<FieldPermissionDetailWrapper>();
        tagProjectList = new List<FieldPermissionDetailWrapper>();
        
        //iteration over all field permissions
        for(FieldPermissions field : fieldPermissions) {
            
            if(identificationFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, identificationFields, identificationList);
            }else if(attributeFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, attributeFields, attributesList);
            }else if(incomeFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, incomeFields, incomeList);
            }else if(electoralFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, electoralFields, electoralList);
            }else if(contactFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, contactFields, contactList);
            }else if(hasContactFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, hasContactFields, hasContactList);
            }else if(tagsFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, tagsFields, tagList);
            }else if(tagsProjectFields.contains(field.Field.split('\\.')[1])){
                createPermissionDetail(field, tagsProjectFields, tagProjectList);
            }
        }
        permissionsList.add(createGroupPermission('Identificacion', identificationList, identificationFields));
        permissionsList.add(createGroupPermission('Atributos', attributesList, attributeFields));
        permissionsList.add(createGroupPermission('Ingresos', incomeList, incomeFields));
        permissionsList.add(createGroupPermission('Electoral', electoralList, electoralFields));
        permissionsList.add(createGroupPermission('Contacto', contactList, contactFields));
        permissionsList.add(createGroupPermission('Contacto(tiene)', hasContactList, hasContactFields));
        permissionsList.add(createGroupPermission('Tags Standard', tagList, tagsFields));
        permissionsList.add(createGroupPermission('Tags x proyecto', tagProjectList, tagsProjectFields));
        return permissionsList;
    }
    
    public List<SystemPermissionWrapper> getSystemPermissions(User user) {
        Schema.DescribeSObjectResult objectDescribe  = Profile.SObjectType.getDescribe();
        List<SystemPermissionWrapper> sysPerList = new List<SystemPermissionWrapper>();
        Profile profile = [SELECT Id, PermissionsApiUserOnly, PermissionsApiEnabled, PermissionsApexRestServices, PermissionsBulkApiHardDelete,
                           PermissionsExportReport, PermissionsRunReports, PermissionsViewSetup, PermissionsEmailMass,
                           PermissionsEmailSingle, PermissionsManageNetworks, PermissionsGovernNetworks, PermissionsManageUsers,
                           PermissionsManageInternalUsers, PermissionsAssignPermissionSets, PermissionsViewAllData, PermissionsModifyMetadata,
                           PermissionsModifyAllData, PermissionsManageIpAddresses, PermissionsAddAnalyticsRemoteConnections FROM Profile WHERE Id =: user.Profile.Id];
        List<PermissionSet> permissionSets = [SELECT Id, PermissionsAddAnalyticsRemoteConnections, PermissionsWaveTabularDownload, PermissionsInsightsAppEltEditor,
                                        PermissionsInsightsAppUser, PermissionsCreateUpdateSDDStory, PermissionsCreateUpdateSDDDataset,
                                        PermissionsInsightsAppAdmin FROM PermissionSet
                                              WHERE Id IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE Assignee.Id =: user.Id ) 
                                              AND (Name = 'EinsteinAnalyticsPlusAdmin' OR Name = 'EinsteinAnalyticsPlusUser') LIMIT 1];
        PermissionSet permissionSet = null;
        if(permissionSets.size() > 0){
            permissionSet = permissionSets[0];
        }
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        for( String fieldName : systemPermissionsFieldsProfile ) {
            Schema.SObjectField field = fieldMap.get( fieldName );
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            SystemPermissionWrapper sysPer = new SystemPermissionWrapper();
            sysPer.name = fieldDescribe.getLabel();
            sysPer.active = (Boolean)profile.get(fieldName);
            sysPerList.add(sysPer);
        }
        if(permissionSet != NULL){
            for( String fieldName : systemPermissionsFieldsPermissionSet ) {
                Schema.SObjectField field = fieldMap.get( fieldName );
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                SystemPermissionWrapper sysPer = new SystemPermissionWrapper();
                sysPer.name = fieldDescribe.getLabel();
                sysPer.active = (Boolean)permissionSet.get(fieldName);
                sysPerList.add(sysPer);
            }
        }
        return sysPerList;    
    }
    
    public List<PermissionSet> getPermissionSets (Id recordId) {
        List<PermissionSet> permissionList = new List<PermissionSet>();
        for (PermissionSet permission : [SELECT Id, Name, Label FROM PermissionSet WHERE Id IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE Assignee.Id =: recordId )]) {
            if(!permission.name.contains('X00e')){
                permissionList.add(permission);
            }
        }
        return permissionList;
    }
    
    public List<CustomPermission> getCustomPermissions (List<PermissionSet> permissionSets) {
        List<CustomPermission> customPermissionList = [SELECT Id, DeveloperName, MasterLabel FROM CustomPermission WHERE Id IN (SELECT SetupEntityId FROM SetupEntityAccess 
                                                       WHERE ParentId IN: (permissionSets) AND SetupEntityType = 'CustomPermission')];
        return customPermissionList;
    }
    
    /* Checks if a field exist in the permissionList and add it if not */
    private void createPermissionDetail (FieldPermissions field, List<String> fieldGroup, List<FieldPermissionDetailWrapper> permissionsList) {
        Boolean existInGroup = false;
        String nameField = field.Field.split('\\.')[1];
        
        //check if the field iterarion already exist on the group
        for (FieldPermissionDetailWrapper item : permissionsList) {
            if(item.fieldName == nameField){
                //if it exist update the permissions ONLY if the previous value was false
                if(!item.readPermission){
                    item.readPermission = field.permissionsRead;
                }
                if(!item.editPermission){
                    item.editPermission = field.permissionsEdit;
                }
                existInGroup = true;
                break;
            }
        }
        //if it doesn't exist in the group then add it
        if(!existInGroup){
            FieldPermissionDetailWrapper fpdw = new FieldPermissionDetailWrapper();
            fpdw.fieldName = nameField;
            fpdw.readPermission = field.permissionsRead;
            if(fpdw.editPermission == NULL || (!fpdw.editPermission && field.PermissionsEdit)){
                fpdw.editPermission = field.PermissionsEdit;
            }
            permissionsList.add(fpdw);   
        }
    }
    
    private GroupPermissionWrapper createGroupPermission (String name, List<FieldPermissionDetailWrapper> permissionsList, List<String> fieldList) {
        GroupPermissionWrapper permission = new GroupPermissionWrapper();
        permission.name = name;
        Integer readCount = 0;
        Integer editCount = 0;
        for (FieldPermissionDetailWrapper item : permissionsList){
            if(item.readPermission){
                readCount ++;
            }
            if(item.editPermission){
                editCount ++;
            }
        }
        if(readCount == fieldList.size() && editCount == fieldList.size()){
            permission.permissionType = 'Read/Write';
        }else if(readCount > 0 && editCount > 0){
            permission.permissionType = 'Read/Write (parcial)';
        }else if(readCount == fieldList.size()){
            permission.permissionType = 'Read Only';
        }else if(readCount > 0){
            permission.permissionType = 'Read Only (parcial)';
        }else {
            permission.permissionType = 'No Access';
        }
        return permission;
    }
    
    private void addMissingFieldsToGroup(List<FieldPermissionDetailWrapper> permissionsList, List<String> fieldNames){
        Boolean existInList;
        //Check if the group does not have all the corresponding fields
        if(permissionsList.size() != fieldNames.size()){
            //iterate over all the fields of the group to see which is missing 
            for(String fieldName : fieldNames){
                existInList = false;
                for(FieldPermissionDetailWrapper item : permissionsList){
                    if(fieldName == item.fieldName){
                        existInList = true;
                        break;
                    }
                }
                //When a missing field is found is created with its permissions set as false
                if(!existInList){
                    FieldPermissionDetailWrapper fpdw = new FieldPermissionDetailWrapper();
                    fpdw.fieldName = fieldName;
                    fpdw.readPermission = false;
                    fpdw.editPermission = false;
                    permissionsList.add(fpdw);
                }
            }
        }
    }
    
    public class GroupPermissionWrapper {
        
        public String name {get;set;}
        public String permissionType {get;set;}
    }
    
    public class SystemPermissionWrapper {
        
        public String name {get;set;}
        public Boolean active {get;set;} 
    }
    
    public class FieldPermissionDetailWrapper {
        public String fieldName {get;set;}
        public Boolean readPermission {get;set;}
        public Boolean editPermission {get;set;}
    }
}