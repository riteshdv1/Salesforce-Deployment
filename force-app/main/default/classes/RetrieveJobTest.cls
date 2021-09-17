@IsTest (isParallel = true)
private class RetrieveJobTest {
    private static final String SUCCESS='SUCCESS';
    private static final String FAILURE='FAILURE';
    private static Environment__c getEnvironment(){
        Environment__c e = new Environment__c();
        e.name = 'abc';
        e.namedcredential__c = 'abc';
        return e;
    }
    
    private static String getPackageInput(){
        return '[{"name":"ApexClass","folderName":"classes","members":[{"name":"RetrieveJob","show":true,"isSelected":true,"class":"background-color:green;color:white;"}],"isSelected":true}]';
    }
    
    private static Retrieve__c getRetrieveJob(Id environmentId, String packageFileContent){
        Retrieve__c retrieveJob = new Retrieve__c();
        retrieveJob.Environment__c = environmentId;
        retrieveJob.PackageFileContent__c = packageFileContent;
        return retrieveJob;
    }

    private static String getZipDataString(){
        return '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';
    }
    
    private static Attachment getAttachment(Blob body, Id parentId){
        Attachment a = new Attachment();
        a.body=body;
        a.parentId=parentId;
        a.name='test file';
        return a;
    }
    
    @isTest
    private static void testNewJob_Success(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveNewJobMockSuccess());
        Test.startTest();
        Id jobId = retrieveJob.newJob(environment.Id, packageInput);
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'Job id is expected');
    }
    
    @isTest
    private static void testNewJob_when_session_timeout(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveNewJobMockInvalidSession());
        Test.setMock(System.HttpCalloutMock.class, new SessionMock());
        Test.startTest();
        Id jobId;
        try{
         jobId = retrieveJob.newJob(environment.Id, packageInput);
         system.assert(false, 'Exception is expected');
        } catch(Exception e){
          System.assert(e instanceOf MetadataOperations.MetadataOperationsException);   
          System.assertEquals(null, jobId, 'Job id not is expected');
        }        
        Test.stopTest();
        
    }
    
    @isTest
    private static void testNewJob_when_exception(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveNewJobMockError());
        Test.startTest();
        Id jobId;
         try{
         jobId = retrieveJob.newJob(environment.Id, packageInput);
         system.assert(false, 'Exception is expected');
        } catch(Exception e){
          System.assert(e instanceOf MetadataOperations.MetadataOperationsException);  
          System.assertEquals(null, jobId, 'Job id not is expected');
        } 
        Test.stopTest(); 
    }
    
    @isTest
    private static void testUpdateStatus_Success(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        Retrieve__c retrieveRecord = getRetrieveJob(environment.Id, packageInput);
        Insert retrieveRecord;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveUpdateStatusMockSuccess());
        Test.startTest();
        RetrieveJob.Response retrieveResponse=retrieveJob.updateStatus(retrieveRecord);
        Test.stopTest();
        System.assertEquals(SUCCESS, retrieveResponse.status, 'Success status is expected');
        System.assertEquals(true, retrieveResponse.hasAttachment, 'Attachment is expected');
    }

    @isTest
    private static void testUpdateStatus_Failure(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        Retrieve__c retrieveRecord = getRetrieveJob(environment.Id, packageInput);
        Insert retrieveRecord;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveUpdateStatusMockFailure());
        Test.startTest();
        RetrieveJob.Response retrieveResponse= retrieveJob.updateStatus(retrieveRecord);
        Test.stopTest();
        System.assertEquals(FAILURE, retrieveResponse.status, 'Failure status is expected'); 
    }
    
    @isTest
    private static void testUpdateStatus_when_session_timeout(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        Retrieve__c retrieveRecord = getRetrieveJob(environment.Id, packageInput);
        Insert retrieveRecord;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveUpdateStatusMockInvalidSession());
        Test.setMock(System.HttpCalloutMock.class, new SessionMock());
        Test.startTest();
        RetrieveJob.Response retrieveResponse;
        try{
            retrieveResponse=retrieveJob.updateStatus(retrieveRecord);
            system.assert(false, 'Exception is expected');
           } catch(Exception e){
             System.assert(e instanceOf MetadataOperations.MetadataOperationsException);   
             System.assertEquals(null, retrieveResponse, 'Job id not is expected');
           }         
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateStatus_when_exception(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        insert environment;
        Retrieve__c retrieveRecord = getRetrieveJob(environment.Id, packageInput);
        Insert retrieveRecord;
        RetrieveJob retrieveJob = new RetrieveJob();
        Test.setMock(System.WebServiceMock.class, new RetrieveUpdateStatusMockError());
        Test.startTest();
        RetrieveJob.Response retrieveResponse;
         try{
            retrieveResponse=retrieveJob.updateStatus(retrieveRecord);
            system.assert(false, 'Exception is expected');
        } catch(Exception e){
          System.assert(e instanceOf MetadataOperations.MetadataOperationsException);  
          System.assertEquals(null, retrieveResponse, 'response is not is expected');
        } 
        Test.stopTest(); 
    }
    
    @isTest
    private static void testCreateMetadata_success(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        Insert environment;
        Retrieve__c retrieveRecord = getRetrieveJob(environment.Id, packageInput);
        Insert retrieveRecord;
        blob zipDataBlob = EncodingUtil.base64Decode(getZipDataString());
        Attachment attachment = getAttachment(zipDataBlob,retrieveRecord.Id);
        Insert Attachment;
        
        Test.startTest();
        RetrieveJob retrieveJob = new RetrieveJob();
        retrieveJob.createMetadata(retrieveRecord.Id);
        Test.stopTest();
        List<RetrieveMetadata__c> retrieveMetadataList = [Select Id FROM RetrieveMetadata__c WHERE JobId__c=:retrieveRecord.Id];
        System.assertNotEquals(0, retrieveMetadataList.size(), 'Retrieve metadatalist should not be empty');  
    }
    
    @isTest
    private static void testCreateMetadata_when_attachment_not_exist(){
        String packageInput = getPackageInput();
        Environment__c environment = getEnvironment();
        Insert environment;
        Retrieve__c retrieveRecord = getRetrieveJob(environment.Id, packageInput);
        Insert retrieveRecord;
        
        Test.startTest();
        RetrieveJob retrieveJob = new RetrieveJob();
        retrieveJob.createMetadata(retrieveRecord.Id);
        Test.stopTest();
        List<RetrieveMetadata__c> retrieveMetadataList = [Select Id FROM RetrieveMetadata__c WHERE JobId__c=:retrieveRecord.Id];
        System.assertEquals(0, retrieveMetadataList.size(), 'Retrieve metadatalist should be empty');  
    }
    
    @isTest
    private static void testGetTypes_Success(){
        
    }
    
    @isTest
    private static void testGetTypes_when_session_timeout(){
        
    }
    
    @isTest
    private static void testGetTypes_when_exception(){
        
    }
    
    @isTest
    private static void testGetElementsByType_Success(){
        
    }
    
    @isTest
    private static void testGetElementsByType_when_session_timeout(){
        
    }
    
    @isTest
    private static void testGetElementsByType_when_exception(){
        
    }
    
    @isTest
    private static void testParseInput_success(){
        
    }
    
    @isTest
    private static void testParseInput_when_failure(){
        
    }
    
    @isTest
    private static void testRefresh_success(){
        
    }
    
    @isTest
    private static void testRefresh_when_failure(){
        
    }
    
    @isTest
    private static void testGetAllInProgressJobs_success(){
        
    }
    
    @isTest
    private static void testGetAllInProgressJobs_failure(){
        
    }
    
    @isTest
    private static void testGetAllJobs_success(){
        
    }
    
    @isTest
    private static void testGetAllJobs_failure(){
        
    } 
    
    //Mocks go here
    public class RetrieveNewJobMockSuccess implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 MetadataService.retrieveResponse_element retrieveResponse = new MetadataService.retrieveResponse_element();
                                 MetadataService.AsyncResult result = new MetadataService.AsyncResult();
                                 result.Id='123456789';
                                 retrieveResponse.result = result; 
                                 response_map_x.put('response_x',retrieveResponse);
                             }
    }
    
    public class RetrieveNewJobMockError implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 CalloutException e = new CalloutException();
                                 e.setMessage('Something wrong');
                                 throw e;
                             }
    }
    
        public class RetrieveNewJobMockInvalidSession implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 CalloutException e = new CalloutException();
                                 e.setMessage('INVALID_SESSION_ID');
                                 throw e;
                             }
    }
    
    public class RetrieveUpdateStatusMockSuccess implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 MetadataService.checkRetrieveStatusResponse_element response_x = new MetadataService.checkRetrieveStatusResponse_element(); 
                                 MetadataService.RetrieveResult result = new MetadataService.RetrieveResult();                            
                                 result.done=true;
                                 result.status='Succeeded';
                                 result.zipFile=EncodingUtil.base64Encode(Blob.valueOf('some text'));
                                 response_x.result = result; 
                                 response_map_x.put('response_x',response_x);
                             }
    }

    public class RetrieveUpdateStatusMockFailure implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 MetadataService.checkRetrieveStatusResponse_element response_x = new MetadataService.checkRetrieveStatusResponse_element(); 
                                 MetadataService.RetrieveResult result = new MetadataService.RetrieveResult();                            
                                 result.done=true;
                                 result.status='Failure';
                                 response_x.result = result; 
                                 response_map_x.put('response_x',response_x);
                             }
    }
    
    public class RetrieveUpdateStatusMockError implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 CalloutException e = new CalloutException();
                                 e.setMessage('Something wrong');
                                 throw e;
                             }
    }
    
        public class RetrieveUpdateStatusMockInvalidSession implements WebServiceMock{
        public void doInvoke(Object stub,
                             Object request_x,
                             Map<String, Object> response_map_x,
                             String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType){
                                 CalloutException e = new CalloutException();
                                 e.setMessage('INVALID_SESSION_ID');
                                 throw e;
                             }
    }
}