global without sharing class CommunityController {
    @AuraEnabled
    global static List<Product2> getActiveProducts(){
        List<Product2> activePRS = [SELECT Id, Name, DisplayURL, isActive, Price__c 
                                    FROM Product2
                                    WHERE isActive = True
                                   ];
        return activePRS;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getAllCars() {
        return [SELECT Id, Name, Model__c, Brand__c, DisplayUrl, Color__c, IsActive, Price__c FROM Product2];
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getCars() {
        return [SELECT Id, Name, Model__c, Brand__c, DisplayUrl, Color__c, IsActive, Price__c FROM Product2 WHERE IsActive = True];
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getAvailableCars(String model, String brand, String color){
      String query = 'SELECT Id, Name, Model__c, Brand__c, Color__c, Price__c, DisplayUrl, IsActive FROM Product2 WHERE IsActive = TRUE';
      
      if(model != null && model != ''){
        query += ' AND Model__c = \'' + model + '\'';
      }

      if(brand != null && brand != ''){
        query += ' AND Brand__c = \'' + brand + '\'';
      }

      if(color != null && color != ''){
        query += ' AND Color__c = \'' + color + '\'';
      }
      
      return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    global static List<Lead> getWebToLeadLeads(){
        List<Lead> allWebToLeadLeads = [SELECT Id, FirstName, LastName, Email, Company, City, State, LeadSource 
                                        FROM Lead 
                                        WHERE LeadSource = 'WebToLead'
                                        ];
        return allWebToLeadLeads;
    }

    @AuraEnabled
    global static void leadToUpt(Id leadId, String FName, String LName, String Email, String Company, String City, String State){
        Lead leadToUpdate = new Lead(
            Id = leadId,
            FirstName = FName,
            LastName = LName,
            Email = Email,
            Company = Company,
            City = City,
            State = State
        );
        update leadToUpdate;
    }

    @AuraEnabled
    global static Boolean isAdmin(Id userId){
        List<PermissionSetAssignment> permission = [
            SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
            FROM PermissionSetAssignment 
            WHERE Assignee.id = :userId 
            AND PermissionSet.Name = 'Admin_User' 
        ];
        return permission.size()>0 ? true : false;
    }

    @AuraEnabled
    global static List<PermissionSetAssignment> getAdminUsers(){
       List<PermissionSetAssignment> users = [SELECT Id, PermissionSetId, AssigneeId, Assignee.Name 
                        FROM PermissionSetAssignment 
                        WHERE PermissionSet.Name = 'Admin_User'
                        ];
        return users;
    }

    @AuraEnabled
    public static void assignUser(Id recordId, Id userId){
        Lead leadToBeAssigned = [SELECT Id, Name, OwnerId
                                 FROM Lead
                                 WHERE Id = :recordId
                                 ];
        leadToBeAssigned.Id = recordId;
        leadToBeAssigned.OwnerId = userId;
        
        update leadToBeAssigned;
    }

    /*
   * @method uploadFile() 
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * @param {String} recordId - Id of the record you want to attach this file to
   * 
   * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
   *   upload was successful, otherwise returns null
   */
   @AuraEnabled
   public static String uploadFile(String base64, String filename, String recordId) {
         ContentVersion cv = createContentVersion(base64, filename);
         ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
         createURL(filename, recordId, cv.Id);

         if (cv == null || cdl == null) { return null; }
         return cdl.Id;
   }

   private static void createURL(String filename, String recordId, String cvId){
    ContentDistribution cd = new ContentDistribution(
        Name = filename,
        ContentVersionId = cvId,
        PreferencesAllowViewInBrowser = true);
    insert cd;
    String url = [  SELECT Id, ContentVersionId, Name, ContentDownloadUrl 
                    FROM ContentDistribution 
                    WHERE ContentVersionId = :cvId].ContentDownloadUrl;
    Product2 product = new Product2(Id = recordId, DisplayUrl = url);
    update product;
    }
   /*
   * @method createContentVersion() [private]
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * 
   * @return {ContentVersion} - returns the newly created ContentVersion, or null
   *   if there was an error inserting the record
   */
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }

    /*
    * @method createContentLink() [private]
    * @desc Creates a content link for a given ContentVersion and record
    * 
    * @param {String} contentVersionId - Id of the ContentVersion of the file
    * @param {String} recordId - Id of the record you want to attach this file to
    * 
    * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
    *   or null if there was an error inserting the record
    */
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
        insert cdl;
        return cdl;
        } catch(DMLException e) {
        System.debug(e);
        return null;
        }
    }

    @AuraEnabled
    public static List<SimulatorProperties> simulator(Decimal price, Decimal downPayment, String termOfSimulator){
        List<SimulatorProperties> paymentCalculation = new List<SimulatorProperties>();
        Integer term = Integer.valueOf(termOfSimulator);
        Decimal totalDebt = price - downPayment;
        Decimal monthlyPayment = totalDebt / term;
        for(Integer i = 0; i <= term; i++){
            SimulatorProperties calculation = new SimulatorProperties();
            if(i == 0){
                calculation.term = i;
                calculation.totalPaidAmount = 0;
                calculation.monthlyPayment = monthlyPayment;
                calculation.unpaidBalanced = totalDebt;
            }else{
                calculation.term = i;
                calculation.totalPaidAmount = monthlyPayment*i;
                calculation.monthlyPayment = monthlyPayment;
                calculation.unpaidBalanced = totalDebt - (monthlyPayment*i);
            }
            paymentCalculation.add(calculation);
        }
        return paymentCalculation;
    }

    public class SimulatorProperties{
        @AuraEnabled
        public Integer term;
        @AuraEnabled
        public Decimal totalPaidAmount;
        @AuraEnabled
        public Decimal monthlyPayment;
        @AuraEnabled
        public Decimal unpaidBalanced;
    }
}
