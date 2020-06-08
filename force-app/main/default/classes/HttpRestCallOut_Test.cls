/**
 * @Component Name      HttpRestCallOut_Test
 * @Created Date        May 11, 2020
 * @Description         The test coverage for HttpRestCallOut and Logger class
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By: Gaurav Trivedi
 * @Last Modified On: 6/5/2020, 11:36:25 AM
 * @Modification Log
 * **********************************************************************************************************************
 *										Modification Log
 * **********************************************************************************************************************
 *  Name				|	Version		|		Date		|					Discription
 * **********************************************************************************************************************
 *	Gaurav Trivedi      |       1.0     |	May 11, 2020	|	Initial Draft
 * **********************************************************************************************************************
 */
@isTest
public with sharing class HttpRestCallOut_Test {
    /**
     * @function    httpCalloutTest
     * @description test the httpCallout basic information
     */
    @isTest
    static void httpCalloutTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName ='TestConfiguration_all' LIMIT 1];
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            String contentType = response.getHeader('Content-Type');
            System.assert (contentType == 'application/json');
            String actualValue = response.getBody();
            String expectedValue = '{"name" : "HttpTest"}';
            System.assertEquals(actualValue, expectedValue);
            System.assertEquals(200, response.getStatusCode());
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    setStringBodyTest
     * @description test the httpCallout with string body
     */
    @isTest
    static void setStringBodyTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessStringBodyResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            HttpRestCallOut.setBody('New Body');
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            String expectedValue = 'New Body';
            System.assertEquals(response.getBody(), expectedValue);
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    setBlobBodyTest
     * @description test the httpCallout with blob body
     */
    @isTest
    static void setBlobBodyTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessBlobBodyResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            Blob body = Blob.valueOf('{"Name" : "Trivedi"}');
            HttpRestCallOut.setBody(body);
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            System.assertEquals(response.getBodyAsBlob(), body);
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    setDocBodyTest
     * @description test the httpCallout with Doc (XML) body
     */
    @isTest
    static void setDocBodyTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessStringBodyResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
            String serviceNS = 'http://www.myservice.com/services/MyService/';
            dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
            envelope.setNamespace('xsi', xsi);
            envelope.setAttributeNS('schemaLocation', soapNS, xsi, null);
            dom.XmlNode body= envelope.addChildElement('Body', soapNS, null);
            body.addChildElement('echo', serviceNS, 'req').addChildElement('category', serviceNS, null).addTextNode('classifieds');
            HttpRestCallOut.setBody(doc);
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            System.assertEquals(200, response.getStatusCode());
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    parameterTest
     * @description parameter test transformation in the endpoint
     */
    @isTest
    static void parameterTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            HttpRestCallOut.setUrlParameter(new Map<String,String> {'${userId}' => UserInfo.getProfileId()});
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            String contentType = response.getHeader('Content-Type');
            System.assertEquals(200, response.getStatusCode());
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    failureTest
     * @description test for failure scenario with 400 status code
     */
    @isTest
    static void failureTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new FailureResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            System.assertEquals(400, response.getStatusCode());
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    withoutServiceNameTest
     * @description test for no service name present in the system.
     */
    @isTest
    static void withoutServiceNameTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessResponseMock());
            HttpResponse response = HttpRestCallOut.makeRestApiCall('No Service');
            System.assertEquals(400, response.getStatusCode());
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    headerTest
     * @description test to set dynamic header for callout
     */
    @isTest
    static void headerTest(){
        try{
            Test.setMock(HttpCalloutMock.class, new SuccessStringBodyResponseMock());
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            HttpRestCallOut.headerMap = new Map<String,String> {'Access'=>'true'};
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            System.assertEquals('true',response.getHeader('Access'), 'Header check');
        }catch(Exception e) {
            System.debug(e);
        }
    }
    /**
     * @function    loggerTest
     * @description Logger class test
     */
    @isTest
    static void loggerTest(){
        try{
            Logger.start();
            Test.setMock(HttpCalloutMock.class, new SuccessResponseMock());
            HttpRestCallOut callout = new HttpRestCallOut();
            APIParameter__mdt apiParameters = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE DeveloperName = 'TestConfiguration_dev' LIMIT 1];
            HttpResponse response = HttpRestCallOut.makeRestApiCall(apiParameters.MasterLabel);
            Logger.apiLog();
            System.assertEquals(200, response.getStatusCode());
        }catch(Exception e) {
            System.debug(e);
        }
    }

    public with sharing class SuccessResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"name" : "HttpTest"}');
            response.setStatusCode(200);
            return response;
        }
    }
    public with sharing class SuccessStringBodyResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            String body = 'New Body';
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Access', 'true');
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
    public with sharing class SuccessBlobBodyResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            Blob body = Blob.valueOf('{"Name" : "Trivedi"}');
            response.setBodyAsBlob(body);
            response.setStatusCode(200);
            return response;
        }
    }

    public with sharing class FailureResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"name" : "HttpTest"}');
            response.setStatusCode(400);
            return response;
        }
    }
}