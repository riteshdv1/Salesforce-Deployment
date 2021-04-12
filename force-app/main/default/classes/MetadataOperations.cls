public virtual with sharing class MetadataOperations {
    protected final String IN_PROGRESS='In Progress';
    protected final String SUCCESS='SUCCESS';
    protected final String FAILURE='FAILURE';
    protected final Integer MAX_RETRY = 2;
    public static final Double version = 50.0;
    protected Environment environment;
    
    public MetadataOperations(){
        if(this.environment == null){
            this.environment = new Environment();
        }        
    }
    
    protected MetadataService.MetadataPort createService(Environment__c envRecord) { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.endpoint_x = 'callout:'+envRecord.NamedCredential__c + '/services/Soap/m/'+String.valueOf(version);
        service.SessionHeader.sessionId = '{!$Credential.OAuthToken}';
        return service;     
    }  
    
    public class ComponentFailure{
        public String fileName {get; set;}
        public Integer line {get; set;}
        public Integer column {get; set;}
        public String problem {get; set;}
        public String componentType {get; set;}
    }
    
    public class Session{
        public boolean isInvalid(System.CalloutException e){
            return e.getMessage().contains('INVALID_SESSION_ID');  
        }
        
        public void refresh(String namedCredential){
            //Dummy rest call to refresh session id
            String restUrl = 'callout:'+namedCredential+'/services/data/v'+String.valueOf(MetadataOperations.version)+'/limits';
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(restUrl);
            req.setMethod('GET');
            HttpResponse res = h.send(req);  
        }        
    }
    
    public class MetadataOperationsException extends Exception{}
}