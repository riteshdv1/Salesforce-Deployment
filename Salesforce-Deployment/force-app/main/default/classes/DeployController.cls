/*
* Controller for Deploy LWC
* 
*/
public with sharing class DeployController {   
    private static final String SUCCESS = 'Success';
    private static final String FAILURE = 'Failure';
    private static final String IN_PROGRESS = 'In Progress';
    private static DeployJob deployObject = new DeployJob();
    
    @AuraEnabled
    public static String createNewDeployJob(String environmentId, String retrieveJobId, String optionsString){
        try{
            ValidationResponse inputValidationResult = validateCreateRequest(environmentId, retrieveJobId, optionsString);
            if(!inputValidationResult.success){
                return inputValidationResult.errorString;
            }
            DeployJob.Options deployOptions = (DeployJob.Options) JSON.deserialize(optionsString, DeployJob.Options.class);
            return deployObject.newJob(environmentId, retrieveJobId, deployOptions);
        } catch(exception e){
            return e.getMessage(); 
        }        
    }    
    
    private static ValidationResponse validateCreateRequest(Id environmentId, Id retrieveJobId, String optionsString){
        if(String.isBlank(environmentId)){
            return new ValidationResponse(false,'EnvironmentId should not be blank');            
        } else if(String.isBlank(retrieveJobId)){ 
            return new ValidationResponse(false,'retrieveJobId should not be blank');
        } else if(String.isBlank(optionsString)){ 
            return new ValidationResponse(false,'options should not be blank');
        }
        return new ValidationResponse(true,'Success');
    }
    
    @AuraEnabled
    public static String refresh(){
        try{            
            deployObject.refresh();
            return SUCCESS;
        } catch(Exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static List<Deploy__c> getAllDeployJobs(){
        return deployObject.getAllJobs();
    }
    
    @AuraEnabled
    public static String cancelDeploy(Id deployJobId){
        try{
            if(String.isBlank(deployJobId)){
                return 'deployJobId should not be blank';
            }
            deployObject.cancelJob(deployObject.getJobById(deployJobId));
            return SUCCESS;    
        } catch(Exception e){
            return e.getMessage();
        }
    }
}