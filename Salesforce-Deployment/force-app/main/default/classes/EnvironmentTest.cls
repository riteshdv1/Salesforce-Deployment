@IsTest (isParallel = true)
private class EnvironmentTest {
    
    @IsTest
    private static void getEnvironment_when_exists(){
        Environment__c e = new Environment__c();
        e.name = 'abc';
        e.namedcredential__c = 'abc';
        Insert e;
        Test.startTest();
        Environment envObject = new Environment();
        Environment__c resultEnvironment = envObject.get(e.Id);
        Test.stopTest();
        System.assertEquals('abc', e.NamedCredential__c, 'Named credential did not match');
    }
    
    @IsTest
    private static void getEnvironment_when_not_exists(){
        Environment__c e = new Environment__c();
        e.name = 'abc';
        e.namedcredential__c = 'abc';
        Insert e;
        Retrieve__c retrieveJob = new Retrieve__c();
        retrieveJob.Environment__c = e.Id;
        retrieveJob.PackageFileContent__c = 'Some content';
        Insert retrieveJob;
        Test.startTest();
        Environment envObject = new Environment();
        Environment__c resultEnvironment = envObject.get(retrieveJob.Id);              
        Test.stopTest();
        System.assertEquals(null, resultEnvironment, 'Null is expected');
    }
    
}