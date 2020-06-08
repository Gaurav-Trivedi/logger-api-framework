/**
 * @Component Name      API_FrontDoor
 * @Created Date        May 12, 2020
 * @Description         This will be the front door for all API we have exposed to external Applications.This class 
 *                      contains all primary HTTP methods for doing GET, POST, PUT, PATCH and DELETE functions.These 
 *                      request methods indicate the desired action to be performed for a given resource.It also checks 
 *                      if the configuration for an API is present with proper service name in custom metadata and then 
 *                      executes the process written in the new service class .
 * @Test Class          API_FrontDoor_Test with test coverage of 91%
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By    : Gaurav Trivedi
 * @Last Modified On    : 6/5/2020, 12:04:18 PM
 * @Modification Log
 * **********************************************************************************************************************
 *                                      Modification Log
 * **********************************************************************************************************************
 *  Name                |   Version     |       Date        |                   Discription
 * **********************************************************************************************************************
 *  Gaurav Trivedi      |       1.0     |   May 12, 2020    |   Initial Draft
 * **********************************************************************************************************************
 * DO NOT CHANGE THIS CLASS
 */
@RestResource(urlMapping='/sffrontdoor/*')
global with sharing class API_FrontDoor {
    public static API_Processor.RallyRestResponse response;
    public static API_Processor.RallyRestRequest request;
    /**
     * @function    putData
     * @description use to handle PUT request
     */
    @HttpPut
    global static API_Processor.RallyRestResponse putData() {
        Logger.start();
        configurationCheck();
        return response;
    }
    /**
     * @function    getData
     * @description use to handle GET request
     */
    @HttpGet
    global static API_Processor.RallyRestResponse getData() {
        Logger.start();
        configurationCheck();
        return response;
    }
    /**
     * @function    deleteData
     * @description use to handle DELETE request
     */
    @HttpDelete
    global static API_Processor.RallyRestResponse deleteData() {
        Logger.start();
        configurationCheck();
        return response;
    }
    /**
     * @function    postData
     * @description use to handle POST request
     */
    @HttpPost
    global static API_Processor.RallyRestResponse postData() {
        Logger.start();
        configurationCheck();
        return response;
    }
    /**
     * @function    patchData
     * @description use to handle PATCH request
     */
    @HttpPatch
    global static API_Processor.RallyRestResponse patchData() {
        Logger.start();
        configurationCheck();
        return response;
    }
    /**
     * @function    configurationCheck
     * @description this function is use to checks if the configuration for an API is present with proper service name in custom metadata and then executes the process written in the new service class .
     */
    static void configurationCheck(){
        List<String> uriList = RestContext.request.requestURI.split('/');
        String apiVersion = uriList.size() > 2 ? uriList[2] : null;
        String serviceName = uriList.size() > 3 ? uriList[3] : null;
        request = new API_Processor.RallyRestRequest(serviceName, RestContext.request);
        try{
            if(API_StatusMessage.responseStatus(serviceName, apiVersion)) {
                API_Interface instance = (API_Interface)Type.forName (API_StatusMessage.className).newInstance();
                instance.preProcess(request);
                response = instance.processRequest();
            }else{
                String message = 'Configuration missing or marformed URL. Please check the service for requested URI: '+RestContext.request.requestURI;
                response = new API_Processor.RallyRestResponse (null, message, 417);
                throw new DmlException(message);
            }
        }catch(Exception e) {
            Logger.apiException(e);
        }finally{
            Logger.apiLog();
        }
    }
}