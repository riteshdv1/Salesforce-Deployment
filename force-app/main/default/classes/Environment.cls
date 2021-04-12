public class Environment { 
    private static Map<Id, Environment__c> environments;
    static{
        environments = new Map<Id, Environment__c>([SELECT Id,NamedCredential__c FROM Environment__c]);
    }
    public Environment__c get(Id environmentId){        
            return environments.get(environmentId);        
    } 
}