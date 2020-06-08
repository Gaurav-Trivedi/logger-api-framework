/**
 * @Component Name API_EnvironmentConfiguration
 * @Created Date   May 4, 2020
 * @Description    This class is use for consuming an API from external environment
 * @Author         Gaurav Trivedi
 * @Group
 * @Last Modified By: Gaurav Trivedi
 * @Last Modified On: 6/4/2020, 3:40:36 PM
 * @Modification Log
 * **********************************************************************************************************************
 *										Modification Log
 * **********************************************************************************************************************
 *  Name				|	Version		|		Date		|					Discription
 * **********************************************************************************************************************
 *	Gaurav Trivedi      |       1.0     |	May 4, 2020	|	Initial Draft
 * **********************************************************************************************************************
 *  NOTE DO NOT CHANGE THIS CLASS
 */
public with sharing class API_EnvironmentConfiguration {
    static APIParameter__mdt restApiParameter;
    /**
     * @function    environmentCheck
     * @description Check if environment configuration is required
     * @param       environment Environment name, like Prod, UAT, Staging or Dev
     * @return boolean true|false
     */
    static Boolean environmentCheck(String environment){
        return URL.getSalesforceBaseUrl().getHost().containsIgnoreCase(environment);
    }
    /**
     * @function    getConfiguration
     * @description This function is used to get the configuration of integration
     * @param       serviceType integration service name, this should be same as the Label of APIParameter__mdt
     */
    public static APIParameter__mdt getConfiguration(String serviceType){
        Logger.start();
        try{
            List<APIParameter__mdt> restApiParameterList = new List<APIParameter__mdt>();
            restApiParameterList = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, EndPoint__c, Type__c, ClientKey__c, ClientSecret__c, RequestMethod__c, Timeout__c, ClientCertificateName__c, EnvironmentType__c, SampleJsonRequest__c, SampleJsonResponse__c, Header__c, Compression__c FROM APIParameter__mdt WHERE MasterLabel =: serviceType];
            restApiParameter = new APIParameter__mdt();
            if(restApiParameterList.size() == 0) {
                throw new DmlException('Please create RestAPIParameter configuration.');
            }else if(restApiParameterList.size() == 1) {
                restApiParameter = restApiParameterList[0];
            }else {
                for(APIParameter__mdt apiParameter : restApiParameterList) {
                    //Check for production
                    if(environmentCheck(System.Label.Production_URL) && apiParameter.EnvironmentType__c.containsIgnoreCase('prod')) {
                        restApiParameter = apiParameter;
                        break;
                    }
                    //Check for QA or UAT sandbox
                    if(environmentCheck(apiParameter.EnvironmentType__c)) {
                        restApiParameter = apiParameter;
                        break;
                    }else if(apiParameter.EnvironmentType__c.containsIgnoreCase('dev')) {
                        restApiParameter = apiParameter;
                    }
                }
            }
        }catch(Exception e) {
            Logger.exception(e);
        }
        return restApiParameter;
    }
}