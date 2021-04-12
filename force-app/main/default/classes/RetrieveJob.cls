public with sharing class RetrieveJob extends MetadataOperations{   
    public RetrieveJob(){
        this.environment = new Environment();
    }
    public Id newJob(Id environmentId, String packageInput){ 
        Integer retryCount = 0;
        List<MetadataService.PackageTypeMembers> types = parseInput(packageInput);
        Environment__c environment = this.environment.get(environmentId);
        MetadataService.AsyncResult asyncResult;
        while(retryCount < MAX_RETRY){
            try{
                MetadataService.MetadataPort service = createService(environment);
                MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
                retrieveRequest.apiVersion = version;
                retrieveRequest.packageNames = null;
                retrieveRequest.singlePackage = true;
                retrieveRequest.specificFiles = null;
                retrieveRequest.unpackaged = new MetadataService.Package_x();
                retrieveRequest.unpackaged.types = types;
                asyncResult = service.retrieve(retrieveRequest); 
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
        Retrieve__c retrieveJob = new Retrieve__c(); 
        retrieveJob.status__c = IN_PROGRESS;
        retrieveJob.environment__c = environmentId;
        retrieveJob.packageFileContent__c = packageInput;
        retrieveJob.packageContentJson__c = JSON.serialize(types);
        retrieveJob.AsyncResultId__c = asyncResult.Id;
        Insert retrieveJob;
        return retrieveJob.Id;
    }
    
    
    
    public Response updateStatus(Retrieve__c retrieveJob){
        Integer retryCount = 0;
        Environment__c environment = this.environment.get(retrieveJob.Environment__c);
        MetadataService.RetrieveResult retrieveResult;
        while(retryCount < MAX_RETRY){
            try{
                MetadataService.MetadataPort service = createService(environment);
                retrieveResult = service.checkRetrieveStatus(retrieveJob.AsyncResultId__c, true); 
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
        
        Response retrieveResponse = new Response();
        if(retrieveResult.done && !retrieveResult.status.equalsIgnoreCase('Succeeded')){
            retrieveResponse.status = FAILURE;
            retrieveResponse.isUpdate = true;
        } else if(retrieveResult.done && retrieveResult.status.equalsIgnoreCase('Succeeded')){                
            Attachment attachment = new Attachment();
            attachment.Body = EncodingUtil.base64Decode(retrieveResult.zipFile);
            attachment.Name = retrieveJob.Name+'.txt';
            attachment.ParentId = retrieveJob.Id; 
            retrieveResponse.attachment = attachment;
            retrieveResponse.status = SUCCESS;
            retrieveResponse.isUpdate = true;
            retrieveResponse.hasAttachment = true;
        }
        return retrieveResponse;
    }
    
    public void createMetadata(Id retrieveJobId){
        RetrieveMetadataBatch retBatch = new RetrieveMetadataBatch(retrieveJobId);
        Database.executeBatch(retBatch);
    }
    
    public List<MetadataService.DescribeMetadataObject> getTypes(Id environmentId, Double version){
        Integer retryCount = 0;
        Environment__c environment = this.environment.get(environmentId);
        while(retryCount < MAX_RETRY){
            try{
                Double asOfVersion = version;
                MetadataService.MetadataPort service = createService(environment);
                MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(asOfVersion);
                MetadataService.DescribeMetadataObject[] metadataObjects = describeResult.metadataObjects;
                metadataObjects.sort();
                return metadataObjects;
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
        return null;        
    }
    
    public List<MetadataService.FileProperties> getElementsByType(Id environmentId, String type_x,String folderName, Double version){
        Integer retryCount = 0;
        Environment__c environment = this.environment.get(environmentId);
        while(retryCount < MAX_RETRY){
            try{
                Double asOfVersion = version;
                MetadataService.MetadataPort service = createService(environment);
                MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
                query.type_x = type_x;
                query.folder = folderName;
                MetadataService.FileProperties[] fileProperties = service.listMetadata(new List<MetadataService.ListMetadataQuery>{query}, asOfVersion);
                return fileProperties;
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
        return null; 
    }
    
    public List<MetadataService.PackageTypeMembers> parseInput(String jsonString){
        List<MetadataService.PackageTypeMembers> types = new List<MetadataService.PackageTypeMembers>();
        List<Object> inputList= (List<Object>)JSON.deserializeUntyped(jsonString);
        for(Object inputObject : inputList){            
            Map<String, Object> inputMap = (Map<String, Object>)inputObject;
            if(inputMap.containsKey('isSelected') && (Boolean)inputMap.get('isSelected')){
                MetadataService.PackageTypeMembers type_x = new MetadataService.PackageTypeMembers();
                List<Object> inputMembers = (List<object>)inputMap.get('members'); 
                List<String> members = new List<String>();
                for(Object member : inputMembers){
                    Map<String, Object> memberMap = (Map<String, Object>)member;
                    if(memberMap.containsKey('isSelected') && (Boolean)memberMap.get('isSelected')){
                        members.add((String)memberMap.get('name'));   
                    }                
                }
                type_x.name = (String)inputMap.get('name');
                type_x.members = members;
                types.add(type_x);  
            }   
        }        
        return types;
    }
    
    public void refresh(){          
        List<Retrieve__c> retrieveJobs = getAllInProgressJobs();
        List<Attachment> attachments = new List<Attachment>();
        List<Retrieve__c> updateableRetrieveJobs = new List<Retrieve__c>(); 
        for(Retrieve__c retrieveJob : retrieveJobs){
            try{
                Response retrieveResponse = updateStatus(retrieveJob);
                if(retrieveResponse.isUpdate){
                    Retrieve__c tempJobObject = retrieveJob;                        
                    tempJobObject.Status__c =  retrieveResponse.status;
                    updateableRetrieveJobs.add(tempJobObject);
                }
                if(retrieveResponse.hasAttachment){
                    attachments.add(retrieveResponse.attachment);
                    createMetadata(retrieveJob.Id);
                } 
            } catch(Exception e){
                Retrieve__c tempJobObject = retrieveJob;                        
                tempJobObject.Status__c =  FAILURE;
                updateableRetrieveJobs.add(tempJobObject);
            }                
        }
        if(!updateableRetrieveJobs.isEmpty()){
            update updateableRetrieveJobs;
        }
        if(!attachments.isEmpty()){
            Insert attachments;
        }        
    }
    
    public List<Retrieve__c> getAllInProgressJobs(){
        return [SELECT Id, Name, Status__c, Environment__c, AsyncResultId__c FROM Retrieve__c WHERE Status__c = 'In Progress'];
    }
    
    public List<Retrieve__c> getAllJobs(){
        return [SELECT Id, Name, Status__c, CreatedDate, CreatedById, CreatedBy.Name, Environment__r.Name, Environment__c, PackageFileContent__c, PackageContentJson__c FROM Retrieve__c Order By Name desc];
    }
    
    public class Response{
        public String status {get; private set;}
        public Attachment attachment {get; private set;}
        public Boolean isUpdate {get; private set;}
        public Boolean hasAttachment {get; private set;}
        public Response(){
            this.isUpdate = false;
            this.hasAttachment = false;
        }
    }
}