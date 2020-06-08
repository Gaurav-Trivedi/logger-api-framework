/**
 * @Component Name HttpRestCallOut
 * @Created Date   May 4, 2020
 * @Description    Utility class to make HTTP Rest Call out from Salesforce. This class will execute the request if the 
 *                 API parameter custom metadata type configuration is present with proper service name .
 * @Test Class     HttpRestCallOut_Test with code coverage 98%
 * @Author         Gaurav Trivedi
 * @Group
 * @Last Modified By: Gaurav Trivedi
 * @Last Modified On: 6/5/2020, 11:38:03 AM
 * @Modification Log
 * **********************************************************************************************************************
 *										Modification Log
 * **********************************************************************************************************************
 *  Name				|	Version		|		Date		|					Discription
 * **********************************************************************************************************************
 *	Gaurav Trivedi      |       1.0     |	May 4, 2020	|	Initial Draft
 * **********************************************************************************************************************
 */
public with sharing class HttpRestCallOut {
    public HttpRestCallOut() {
        Logger.start();
    }
    static Dom.Document bodyAsDocument;
    static Blob bodyAsBlob;
    static String body;
    static Map<String,String> urlParameterMap = new Map<String,String>();
    static APIParameter__mdt apiParameters;
    static HttpRequest request = new HttpRequest();
    public static Map<String,String> headerMap = new Map<String, String>();
    public static API_Processor.RallyHttpRequest rallyRequest;
    public static API_Processor.RallyRestResponse rallyResponse;

    /**
     * @function    makeRestApiCall
     * @description This method is used to make api callout from Salesforce to external environment/application. In this function the logic will be pulled from Custom Metadata configurations and it is dependent on the Label.
     * @param       serviceName Custom Metadata label.
     * @return      it will return the HttpResponse object, which can be used to run further processing.
     * @example
     * HttpResponse revenueResponse = HttpRestCallOut.makeRestApiCall('Revenue Calculation');
     */
    public static HttpResponse makeRestApiCall(String serviceName){
        HttpResponse response;
        try{
            apiParameters = apiParameters == null ? API_EnvironmentConfiguration.getConfiguration(serviceName) : apiParameters;
            setHeader(apiParameters.Header__c);
            request.setMethod(apiParameters.RequestMethod__c);
            request.setEndpoint(processEndPoint(apiParameters));
            if(apiParameters.Timeout__c <> null) {
                request.setTimeout(Integer.ValueOf(apiParameters.Timeout__c));
            }
            if(String.isNotBlank(apiParameters.ClientCertificateName__c)) {
                request.setClientCertificateName(apiParameters.ClientCertificateName__c);
            }
            if(apiParameters.Compression__c) {
                request.setCompressed(apiParameters.Compression__c);
            }
            if(String.isNotBlank(body)) {
                request.setBody(body);
            }else if(bodyAsDocument <> null) {
                request.setBodyDocument(bodyAsDocument);
            }else if(bodyAsBlob <> null) {
                request.setBodyAsBlob(bodyAsBlob);
            }
            Http h = new Http();
            response = h.send(request);
            rallyRequest = new API_Processor.RallyHttpRequest(serviceName, request, headerMap);
            rallyResponse = new API_Processor.RallyRestResponse(response);
            if(response.getStatusCode() <> null && !String.valueOf(response.getStatusCode()).startsWith('2')) {
                throw new DmlException(response.getStatus());
            }
        }catch(Exception ex) {
            Logger.apiException(ex);
        }
        return response;
    }

    /**
     * @function    setBody
     * @description Use this method to set the body as string for Http callout
     * @param       strBody string body to send in callOut
     * @example
     * String body = '{"Name":"Trivedi"}';
     * HttpRestCallOut.setBody(body);
     */
    public static void setBody(String strBody){
        body = strBody;
    }
    
    /**
     * @function    makeRestApiCall
     * @description Use this method to set the body as Blob for Http callout
     * @param       blobBody set body as blob for callout
     * @example
     * Blob body = Blob.valueOf('{"Name":"Trivedi"}');
     * HttpRestCallOut.setBody(body);
     */
    public static void setBody(Blob blobBody){
        bodyAsBlob = blobBody;
    }

    /**
     * @function    makeRestApiCall
     * @description Use this method to set the body as Dom.Document for process XML content.You can parse nested XML content that’s up to 50 nodes deep.
     * @param       documentBody XML content for callout
     * @example
     * DOM.Document doc = new DOM.Document();
     * String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
     * String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
     * String serviceNS = 'http://www.myservice.com/services/MyService/';
     * dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
     * envelope.setNamespace('xsi', xsi);
     * envelope.setAttributeNS('schemaLocation', soapNS, xsi, null);
     * dom.XmlNode body= envelope.addChildElement('Body', soapNS, null);
     * body.addChildElement('echo', serviceNS, 'req').addChildElement('category', serviceNS, null).addTextNode('classifieds');
     * HttpRestCallOut.setBody(doc);
     */
    public static void setBody(Dom.Document documentBody){
        bodyAsDocument = documentBody;
    }

    /**
     * @function    setUrlParameter
     * @description Use to replace the keys value in the URL meta configuration
     * @param       urlParamMap url parameter map
     * @example
     * Map<String, String> urlParameterMap = new Map<String, String>();
     * urlParameterMap.put('${programid}', 'idOfProgram');
     * urlParameterMap.put('${trackid}', 'idOfTrack');
     * HttpRestCallOut.setUrlParameter(urlParameterMap);
     */
    public static void setUrlParameter(Map<String,String> urlParamMap){
        urlParameterMap = urlParamMap;
    }

    /**
     * @function    processEndPoint
     * @description Use to replace the keys in the URL meta configuration
     * @param       apiParameters Api parameter from the custom metadata
     */
    static String processEndPoint(APIParameter__mdt apiParameters){
        String endPoint = apiParameters.EndPoint__c;
        if(endPoint.contains('${')) {
            if(endPoint.containsIgnoreCase('${signature}')) {
                endPoint = endPoint.replace('${signature}', generateHashCode(true,apiParameters.ClientKey__c,apiParameters.ClientSecret__c));
            }
            if(!urlParameterMap.isEmpty()){
                for(String param: urlParameterMap.keySet()) {
                    endPoint = endPoint.replace(param, urlParameterMap.get(param));
                }
            }
        }
        return endPoint;
    }

    /**
     * @function    setHeader
     * @description use to set headers for HTTP callouts
     * @param       headers Header string from custom metadata
     */
    static void setHeader(String headers){
        if(!headerMap.isEmpty()) {
            for(String key : headerMap.keySet()) {
                request.setHeader(key, headerMap.get(key));
            }
        }
        if(String.isNotBlank(headers)) {
            for(String header: headers.split('\n')) {
                String key = header.split(':')[0];
                String value = header.split(':')[1];
                request.setHeader(key, value);
                headerMap.put(Key, value);
            }
        }
    }

    /**
     * @function    generateHashCode
     * @description Generate hash code for authentication of an API
     * @param       useTimeStamp set true if time stamp is required to hashcode
     * @param       secret client seceret
     * @param       apiKey client Key
     * @return      the hash code for authentication
     */
    static String generateHashCode(Boolean useTimeStamp, String secret, String apiKey){
        String unixTime = '';
        String hashCode = '';
        try{
            if (useTimeStamp) {
                unixTime =  String.valueOf((dateTime.now().getTime()/1000).intValue());
            }
            if (String.isBlank(apiKey) || String.isBlank(secret)) {
                String message = 'Apikey and/or secret are required parameter is not set, cannot be able to proceed!!!';
                throw new DmlException(message);
            }
            Blob targetBlob = Blob.valueOf(apiKey+secret+unixTime);
            hashCode = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', targetBlob));
        }catch(Exception e) {
            Logger.exception (e);
        }
        return hashCode;
    }
}