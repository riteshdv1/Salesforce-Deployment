public class ValidationResponse{
        public Boolean success{get; private set;}
        public String errorString{get; private set;}
        public ValidationResponse(Boolean success, String errorString){
            this.success = success;
            this.errorString = errorString;
        }
    }