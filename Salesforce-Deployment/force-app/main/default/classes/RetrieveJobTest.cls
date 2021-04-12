@IsTest (isParallel = true)
private class RetrieveJobTest {
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
        retrieveJob.updateStatus(retrieveRecord);
        Test.stopTest();
       // System.assertNotEquals(null, jobId, 'Job id is expected'); 
    }
    
    @isTest
    private static void testUpdateStatus_when_session_timeout(){
        
    }
    
    @isTest
    private static void testUpdateStatus_when_exception(){
        
    }
    
    @isTest
    private static void testCreateMetadata_success(){
        
    }
    
    @isTest
    private static void testCreateMetadata_when_attachment_not_exist(){
        
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
                                 MetadataService.retrieveResponse_element retrieveResponse = new MetadataService.retrieveResponse_element();
                                 MetadataService.AsyncResult result = new MetadataService.AsyncResult();
                                 result.Id='123456789';
                                 retrieveResponse.result = result; 
                                 response_map_x.put('response_x',retrieveResponse);
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