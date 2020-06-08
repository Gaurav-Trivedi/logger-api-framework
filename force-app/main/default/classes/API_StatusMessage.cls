/**
 *@Component Name       API_StatusMessage
 * @Created Date        May 12, 2020
 * @Description         This class is used to get all HTTP status messages
 * @Test Class          API_FrontDoor__Test with 100% code coverage
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By    : Gaurav Trivedi
 * @Last Modified On    : 6/4/2020, 1:35:22 PM
 * @Modification Log
 * **********************************************************************************************************************
 *                                      Modification Log
 * **********************************************************************************************************************
 *  Name                |   Version     |       Date        |                   Discription
 * **********************************************************************************************************************
 *  Gaurav Trivedi      |       1.0     |   May 12, 2020    |   Initial Draft
 * **********************************************************************************************************************
 */
public with sharing class API_StatusMessage {
    public static Map<String, ApiStatusMessage__mdt> responseStatusMap;
    public static String className;
    /**
     * @function    responseStatus
     * @description query all metadata for custom message and statuses.
     * @param       serviceName service name of the API
     */
    public static Boolean responseStatus(String serviceName, String apiVersion){
        Boolean isConfigured = false;
        List<APIApexConfiguration__mdt> configurationList = [SELECT ClassName__c, (SELECT DeveloperName, Message__c, MasterLabel FROM ApexConfigurations__r) FROM APIApexConfiguration__mdt WHERE MasterLabel =: serviceName AND APIVersion__c =: apiVersion WITH SECURITY_ENFORCED LIMIT 1];
        if(!configurationList.isEmpty()) {
            isConfigured = true;
            className = configurationList[0].ClassName__c;
            if(configurationList[0].ApexConfigurations__r <> null) {
                responseStatusMap = new Map<String, ApiStatusMessage__mdt>();
                for(ApiStatusMessage__mdt responseStatus: configurationList[0].ApexConfigurations__r ) {
                    responseStatusMap.put(responseStatus.DeveloperName, responseStatus);
                }
            }
        }
        return isConfigured;
    }
}