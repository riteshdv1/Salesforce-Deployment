@isTest (isParallel = true)
private class ValidationResponseTest {
    
    @isTest
    public static void testValidationContructor_success(){
        ValidationResponse response = new ValidationResponse(true, null);
        System.assertEquals(true, response.success, 'true is expected');
        System.assertEquals(null, response.errorString, 'Null is expected');
    }
    
    @isTest
    public static void testValidationContructor_error(){
        String message = 'failure';
        ValidationResponse response = new ValidationResponse(false, message);
        System.assertEquals(false, response.success, 'false is expected');
        System.assertEquals(message, response.errorString, 'message is expected');
    }
    
}