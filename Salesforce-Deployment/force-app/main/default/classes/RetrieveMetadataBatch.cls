public class RetrieveMetadataBatch implements DataBase.Batchable<Attachment> {
    private Id retrieveJobId;
    private Map<String, String> metadataFiles;  
    public RetrieveMetadataBatch(Id retrieveJobId){
        this.retrieveJobId = retrieveJobId; 
    }
    
    public List<Attachment> start(Database.BatchableContext bc){
        return [Select Id,Body,ParentId FROM Attachment where ParentId =: this.retrieveJobId];        
    }
    
    public void execute(Database.BatchableContext bc, List<Attachment> scope){
        Attachment attachmentObject = scope[0];
        unzip(attachmentObject.body);
        createRetrieveMetadata(attachmentObject.ParentId);
    }
    
    public void finish(Database.BatchableContext bc){
        //To do later 
    }
    
    private  void unzip(Blob zipData){
        this.metadataFiles = new Map<String, String>();
        Zippex retrievedZip = new Zippex(zipData);
        Set<String> fileNames = retrievedZip.getFileNames();
        for(String fileName : fileNames){
            String content = retrievedZip.getFile(fileName).toString();
            this.metadataFiles.put(fileName, content);
        }        
    }
    
    private void createRetrieveMetadata(Id jobId){
        List<RetrieveMetadata__c> retrieveMetadataList = new List<RetrieveMetadata__c>();
        for(String fileName : this.metadataFiles.keyset()){
            RetrieveMetadata__c retrieveMetadataRecord = new RetrieveMetadata__c();
            List<String> tempList = fileName.split('/');
            String tempName = tempList.get(tempList.size() - 1);            
            retrieveMetadataRecord.Name = tempName.length() > 80 ? tempName.substring(0, 79) : tempName;
            retrieveMetadataRecord.Content__c = this.metadataFiles.get(fileName);
            retrieveMetadataRecord.JobId__c = jobId;
            retrieveMetadataList.add(retrieveMetadataRecord);
        }
        Insert retrieveMetadataList;
    }
}