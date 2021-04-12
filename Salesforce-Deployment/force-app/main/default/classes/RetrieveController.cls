/*
* Controller for Retrieve LWC
* 
*/
public with sharing class RetrieveController {   
    private static final String SUCCESS = 'Success';
    private static final String FAILURE = 'Failure'; 
    private static final Double version = 50.0;
    private static RetrieveJob retrieveObject = new RetrieveJob();
    
    @AuraEnabled
    public static String createNewRetrieveJob(String environmentId, String packageInputs){
        try{
            ValidationResponse inputValidationResult = validateCreateRequest(environmentId, packageInputs);
            if(!inputValidationResult.success){
                return inputValidationResult.errorString;
            }
            return retrieveObject.newJob(environmentId, packageInputs);
        } catch(exception e){
            return e.getMessage(); 
        }        
    }    
    
    private static ValidationResponse validateCreateRequest(String environmentId, String packageInputs){
        if(String.isBlank(environmentId)){
            return new ValidationResponse(false,'EnvironmentId should not be blank');
            
        } else if(String.isBlank(packageInputs)){ 
            return new ValidationResponse(false,'packageInputs should not be blank');
        }
        return new ValidationResponse(true,'Success');
    }
    
    @AuraEnabled
    public static String refresh(){
        try{            
            retrieveObject.refresh();
            return SUCCESS;
        } catch(Exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<Retrieve__c> getAllRetrieveJobs(){
        return retrieveObject.getAllJobs();
    }
    
    @AuraEnabled
    public static RetrieveResponse getMetadataTypes(Id environmentId){
        try{
            List<MetadataService.DescribeMetadataObject> metadataObjects = retrieveObject.getTypes(environmentId, version);
            return new RetrieveResponse(true, metadataObjects);
        } catch(Exception e){
            return new RetrieveResponse(false, e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static RetrieveResponse getMetadataElementsByType(Id environmentId, String type_x, String folderName){
        try{
            List<MetadataService.FileProperties> fileProperties = retrieveObject.getElementsByType(environmentId, type_x, folderName, version);
            return new RetrieveResponse(true, fileProperties);
        } catch(Exception e){
            return new RetrieveResponse(false, e.getMessage());
        } 
    }
    
    public class RetrieveResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public Object result;
        public RetrieveResponse(Boolean isSuccess, Object result){
            this.isSuccess = isSuccess;
            this.result = result;
        }
    }
}