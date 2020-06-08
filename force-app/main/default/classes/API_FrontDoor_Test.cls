/**
 * @Component Name      API_FrontDoor_Test
 * @Created Date        May 12, 2020
 * @Description         Test Class for API_FrontDoor, API_Processor and Logger classes
 * @Test Class
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By    : Gaurav Trivedi
 * @Last Modified On    : 6/5/2020, 11:59:05 AM
 * @Modification Log
 * **********************************************************************************************************************
 *                                      Modification Log
 * **********************************************************************************************************************
 *  Name                |   Version     |       Date        |                   Discription
 * **********************************************************************************************************************
 *  Gaurav Trivedi      |       1.0     |   May 12, 2020    |   Initial Draft
 * **********************************************************************************************************************
 */
@isTest
private with sharing class API_FrontDoor_Test {
    /**
     * @function    putDataTest
     * @description to test put Data function
     */
    @isTest
    static void putDataTest(){
        String jsonObject = JSON.serialize ('{"name":"This is the body"}');
        RestRequest request = new RestRequest();
        request.requestURI = 'apexrest/sffrontdoor/v1/frontdoortest/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueof(jsonObject);
        RestContext.request = request;
        API_Processor.RallyRestResponse response = API_FrontDoor.putData();
    }
    /**
     * @function    getDataTest
     * @description to test HTTP get function
     */
    @isTest
    static void getDataTest(){
        RestRequest request = new RestRequest();
        request.requestURI = 'apexrest/sffrontdoor/v1/frontdoortest/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        API_Processor.RallyRestResponse response = API_FrontDoor.getData();
    }
    /**
     * @function    postDataTest
     * @description to test HTTP post function
     */
    @isTest
    static void postDataTest(){
        String jsonObject = JSON.serialize ('{"name":"This is the body"}');
        RestRequest request = new RestRequest();
        request.requestURI = 'apexrest/sffrontdoor/v1/frontdoortest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(jsonObject);
        RestContext.request = request;
        API_Processor.RallyRestResponse response = API_FrontDoor.postData();
    }
    /**
     * @function    deleteDataTest
     * @description to test HTTP delete function
     */
    @isTest
    static void deleteDataTest(){
        String jsonObject = JSON.serialize ('{"name":"This is the body"}');
        RestRequest request = new RestRequest();
        request.requestURI = 'apexrest/sffrontdoor/v1/frontdoortest/';
        request.httpMethod = 'DELETE';
        request.requestBody = Blob.valueof(jsonObject);
        RestContext.request = request;
        API_Processor.RallyRestResponse response = API_FrontDoor.deleteData();
    }
    /**
     * @function    patchDataTest
     * @description to test HTTP patch function
     */
    @isTest
    static void patchDataTest(){
        String jsonObject = JSON.serialize ('{"name":"This is the body"}');
        RestRequest request = new RestRequest();
        request.requestURI = 'apexrest/sffrontdoor/v1/frontdoortest/';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueof(jsonObject);
        RestContext.request = request;
        API_Processor.RallyRestResponse response = API_FrontDoor.patchData();
    }
}