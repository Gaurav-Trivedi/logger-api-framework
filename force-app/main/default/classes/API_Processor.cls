/**
 * @Component Name      API_Processor
 * @Created Date        May 11, 2020
 * @Description         API_Processor class is a wrapper class for transforming the request and response
 * @Test Class          API_FrontDoor_Test, Logger_Test and HttpRestCallOut_Test with test coverage of 100%
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By: Gaurav Trivedi
 * @Last Modified On: 6/5/2020, 12:05:51 PM
 * @Modification Log
 * **********************************************************************************************************************
 *										Modification Log
 * **********************************************************************************************************************
 *  Name				|	Version		|		Date		|					Discription
 * **********************************************************************************************************************
 *	Gaurav Trivedi      |       1.0     |	May 11, 2020	|	Initial Draft
 * **********************************************************************************************************************
 */
global with sharing class API_Processor {
    global class RallyRestRequest {
        public String serviceName;
        public String requestType;
        public String remoteAddress;
        public String requestURI;
        public String resourcePath;
        public Map<String,String> headers;
        public Map<String,String> parameters;
        public String requestBody;
        
        public RallyRestRequest(String serviceName, RestRequest request){
            this.serviceName = serviceName;
            this.requestType = request.httpMethod;
            this.parameters = request.params;
            this.headers = request.headers;
            this.requestURI = request.requestURI;
            this.resourcePath = request.resourcePath;
            this.remoteAddress = request.remoteAddress;
            this.requestBody = request.requestBody <> null ? request.requestBody.toString() : null;
        }
    }
    global class RallyHttpRequest {
        public String serviceName;
        public String requestType;
        public Map<String,String> headers;
        public Map<String,String> parameters;
        public String requestBody;
        public String endPoint;
        public RallyHttpRequest(String serviceName, HttpRequest request, Map<String,String> headers){
            this.serviceName = serviceName;
            this.requestBody = request.getBody() <> null ? request.getBody() : request.getBodyAsBlob() <> null ? request.getBodyAsBlob().toString() : request.getBodyDocument() <> null ? request.getBodyDocument().toXmlString() : null;
            this.headers = headers;
            this.requestType = request.getMethod();
            this.endPoint = request.getEndpoint();
        }
    }

    global class RallyRestResponse {
        public Boolean success;
        public ResponseInfo responseInfo = new ResponseInfo();
        public String responseDetail;
       
        public RallyRestResponse(String responseBody, String message, Integer statusCode){
            this.success = statusCode <> null && String.valueOf(statusCode).startsWith('2') ? true : false;
            this.responseInfo.statusCode = statusCode;
            this.responseInfo.message = message;
            this.responseDetail = responseBody;
            RestContext.response.statusCode = statusCode;
        }

        public RallyRestResponse(HttpResponse response){
            this.success = response.getStatusCode() <> null && String.valueOf(response.getStatusCode()).startsWith('2') ? true : false;
            this.responseInfo.statusCode = response.getStatusCode();
            this.responseInfo.message = response.getStatus();
            this.responseDetail = response.getBody() <> null ? response.getBody() : response.getBodyAsBlob() <> null ? response.getBodyAsBlob().toString() : response.getBodyDocument() <> null ? response.getBodyDocument().toXmlString() : null;
        }
    }
    public class ResponseInfo {
        public Integer statusCode;
        public String message;
    }
}