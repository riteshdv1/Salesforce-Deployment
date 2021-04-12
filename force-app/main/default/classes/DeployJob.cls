public with sharing class DeployJob extends MetadataOperations{ 
    private JobAttachments jobAttachments; 
    public DeployJob(){
        this.environment = new Environment();
        this.jobAttachments = new JobAttachments();
    }
    public void loadAllAttachments(List<Id> parentId){
        this.jobAttachments.loadAll(parentId);
    }
    
    public Id newJob(Id environmentId, Id retrieveJobId, Options options){
        Integer retryCount = 0;
        loadAllAttachments(new List<Id>{retrieveJobId});
        List<Attachment> attachments = this.jobAttachments.getByParent(retrieveJobId);
        Environment__c environment = this.environment.get(environmentId);
        MetadataService.AsyncResult asyncResult;
        while(retryCount < MAX_RETRY){
            try{
                MetadataService.MetadataPort service = createService(environment);
                MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
                deployOptions.allowMissingFiles = false;
                deployOptions.autoUpdatePackage = false;
                deployOptions.checkOnly = false;
                deployOptions.ignoreWarnings = false;
                deployOptions.performRetrieve = false;
                deployOptions.purgeOnDelete = false;
                deployOptions.rollbackOnError = true;
                deployOptions.testLevel = options.testLevel;
                deployOptions.runTests = options.runTests;
                deployOptions.singlePackage = true;     
                asyncResult = service.deploy(EncodingUtil.base64Encode(attachments[0].Body), DeployOptions); 
                break;
            } catch(System.CalloutException e){
                if(retryCount < MAX_RETRY-1){
                    Session currentSession = new Session();
                    if(currentSession.isInvalid(e)){
                        currentSession.refresh(environment.NamedCredential__c); 
                    }
                    retryCount++; 
                } else{
                    throw new MetadataOperationsException(e);
                }                
            } 
        }
        Deploy__c deployJob = new Deploy__c();
        deployJob.Retrieve__c = retrieveJobId;
        deployJob.Environment__c = environmentId;
        deployJob.AsyncResultId__c = asyncResult.Id;
        deployJob.Status__c = 'In Progress';
        deployJob.TestLevel__c = options.testLevel;
        Insert deployJob;
        return deployJob.Id;
    }
    
    public Response updateStatus(Deploy__c deployJob){
        Integer retryCount = 0;
        Environment__c environment = this.environment.get(deployJob.Environment__c);
        MetadataService.DeployResult deployResult;
        while(retryCount < MAX_RETRY){
            try{
                MetadataService.MetadataPort service = createService(environment);
                deployResult = service.checkDeployStatus(deployJob.AsyncResultId__c, true);
                break;
            }catch(System.CalloutException e){
                if(retryCount < MAX_RETRY-1){
                    Session currentSession = new Session();
                    if(currentSession.isInvalid(e)){
                        currentSession.refresh(environment.NamedCredential__c); 
                    }
                    retryCount++; 
                } else{
                    throw new MetadataOperationsException(e);
                }                
            }
            
        }        
        Response deployResponse = new Response();
        if(deployResult.done){                            
            if(deployResult.details != null && deployResult.details.componentFailures != null){
                List<ComponentFailure> componentFailures = new List<ComponentFailure>();
                for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                    ComponentFailure componentFailure = new ComponentFailure();
                    componentFailure.fileName = deployMessage.fileName;
                    componentFailure.line = deployMessage.lineNumber;
                    componentFailure.column = deployMessage.columnNumber;
                    componentFailure.problem = deployMessage.problem;
                    componentFailure.componentType = deployMessage.componentType;
                    componentFailures.add(componentFailure);
                }
                deployResponse.componentFailure = JSON.serialize(componentFailures);
            }
            deployResponse.status = deployResult.status.equalsIgnoreCase('Succeeded') ? SUCCESS : FAILURE;
            deployResponse.isUpdate = true;            
        }                  
        return deployResponse; 
    }
    
    public void cancelJob(Deploy__c deployJob){
        Integer retryCount = 0;
        Environment__c environment = this.environment.get(deployJob.Environment__c);
        while(retryCount < MAX_RETRY){
            try{
                MetadataService.MetadataPort service = createService(environment);
                MetadataService.CancelDeployResult cancelDeployResult = service.cancelDeploy(deployJob.AsyncResultId__c);
                break;
            } catch(System.CalloutException e){
                if(retryCount < MAX_RETRY-1){
                    Session currentSession = new Session();
                    if(currentSession.isInvalid(e)){
                        currentSession.refresh(environment.NamedCredential__c); 
                    }
                    retryCount++; 
                } else{
                    throw new MetadataOperationsException(e);
                }                
            }   
        }
    }  
    
    public void refresh(){           
            List<Deploy__c> deployJobs = getAllInProgressJobs();
            List<Deploy__c> updateableDeployJobs = new List<Deploy__c>(); 
            for(Deploy__c deployJob : deployJobs){
                try{
                    Response deployResponse = updateStatus(deployJob);
                    if(deployResponse.isUpdate){
                        Deploy__c tempJobObject = deployJob;                        
                        tempJobObject.Status__c =  deployResponse.status;
                        tempJobObject.ComponentFailures__c = deployResponse.componentFailure;
                        updateableDeployJobs.add(tempJobObject);
                    } 
                } catch(Exception e){
                    Deploy__c tempJobObject = deployJob;                        
                    tempJobObject.Status__c =  FAILURE;
                    updateableDeployJobs.add(tempJobObject);
                }                
            }
            if(!updateableDeployJobs.isEmpty()){
                update updateableDeployJobs;
            } 
    }
    
    public List<Deploy__c> getAllJobs(){
        return [SELECT Id, Name, ComponentFailures__c, CreatedDate, CreatedById, CreatedBy.Name, Environment__c, Environment__r.Name,Retrieve__c,Retrieve__r.name, Retrieve__r.PackageContentJson__c, Status__c FROM Deploy__c Order By Name desc];
    }
    
    public List<Deploy__c> getAllInProgressJobs(){
        return [SELECT Id, Name, Status__c, Environment__c, Retrieve__c, AsyncResultId__c, ComponentFailures__c FROM Deploy__c WHERE Status__c =: IN_PROGRESS];
    }
    
    public Deploy__c getJobById(Id deployJobId){
        return [SELECT Id, Name, Status__c, Environment__c, Retrieve__c, AsyncResultId__c, ComponentFailures__c FROM Deploy__c WHERE Id =: deployJobId];
    }
    
    public class Options{
        public String testLevel;
        public List<String> runTests;
        public Options(){
            this.testLevel = 'NoTestRun';
            this.runTests = new List<String>();
        }
    }
    
    public class Response{
        public String status{private set; get;}
        public String componentFailure{private set; get;}
        public Boolean isUpdate{private set; get;}
        public Response(){
            this.status = 'In Progress';
            this.isUpdate = false;
        }
    }
}