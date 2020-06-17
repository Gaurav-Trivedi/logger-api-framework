/**
 * @Component Name      Logger
 * @Created Date        March 26, 2020
 * @Description         Logger class is for logging all activities for Apex components.The activities will be logged/
 *                      created in Salesforce in asynchronous way, this will help the consumer component to work without
 *                      any additional overhead in terms of performance .
 * @Test Class          Logger_Test, API_FrontDoor_Test and HttpRestCallOut_Test with 90% code coverage
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By    : Gaurav Trivedi
 * @Last Modified On    : 6/16/2020, 12:36:55 PM
 * @Modification Log
 * **********************************************************************************************************************
 *										Modification Log
 * **********************************************************************************************************************
 *  Name				|	Version		|		Date		|					Discription
 * **********************************************************************************************************************
 *	Gaurav Trivedi      |       1.0     |	March 26, 2020	|	Initial Draft
 * **********************************************************************************************************************
 */
public with sharing class Logger {
    static Log__c logRecord = null;
    static Long startTime = null;
    static String processId;
    /*
       Use this if you have to run the logger for different future method
     */
    public static Boolean futureLog = true;

    /**
     * @function    exception
     * @description Use to create an exception record in System Log object
     * @param       e Excaption
     * @example
     * Logger.exception(exceptionObject);
     */
    public static void exception(Exception e){
        checkFutureLog('Exception',null, parameters(e, String.valueOf(timeStamp())), getAllLimits());
    }

    /**
     * @function    exception
     * @description Use to create an exception record in System Log object
     * @param       recordId add recordId if applicable
     * @param       message Add a custom message you want to display on record
     * @param       e Excaption
     * @example
     * Logger.exception(recordId, 'Your custom error message', exceptionObject);
     */
    public static void exception(String recordId, String message, Exception e){
        checkFutureLog('Exception',recordId, parameters(e, message, String.valueOf(timeStamp())), getAllLimits());
    }

    /**
     * @function    apiException
     * @description use this function to log an exception record in System Log object with all performance metrics for
     *              inbound and outbound calls
     * @param       e Exception object
     * @example
     * Logger.apiException(exceptionObject);
     */
    public static void apiException(Exception e){
        try{
            if(API_FrontDoor.request <> null) {
                apiExceptionLog(JSON.serializePretty (API_FrontDoor.request), JSON.serializePretty (API_FrontDoor.response), e, 'Inbound', null, 'Exception');
            }else if(HttpRestCallOut.rallyRequest <> null) {
                apiExceptionLog(JSON.serializePretty (HttpRestCallOut.rallyRequest), JSON.serializePretty (HttpRestCallOut.rallyResponse), e, 'Outbound', null, 'Exception');
            }
        }catch(Exception ex) {
            exception(ex);
        }
    }

    /**
     * @function    apiLog
     * @description use this function to create API log record in System Log object with all performance metrics for
     *              inbound and outbound calls
     * @param       message custom message
     * @example
     * Logger.apiLog('Log message');
     */
    public static void apiLog(String message){
        try{
            DmlException e = new DmlException();
            if(API_FrontDoor.request <> null) {
                apiExceptionLog(JSON.serializePretty (API_FrontDoor.request), JSON.serializePretty (API_FrontDoor.response), e, 'Inbound', message, 'API');
            }else if(HttpRestCallOut.rallyRequest <> null) {
                apiExceptionLog(JSON.serializePretty (HttpRestCallOut.rallyRequest), JSON.serializePretty (HttpRestCallOut.rallyResponse), e, 'Outbound', message, 'API');
            }
        }catch(Exception e) {
            exception(e);
        }
    }

    /**
     * @function    apiLog
     * @description use this function to create API log record in System Log object with all performance metrics for
     *              inbound and outbound calls
     * @example
     * Logger.apiLog();
     */
    public static void apiLog(){
        try{
            apiLog(null);
        }catch(Exception e) {
            exception(e);
        }
    }

    /**
     * @function    start
     * @description Use this function when you want to capture all information about any performance/log/exceptions.
     *              You can call this in Apex execution starting point. Note: there won't be big harm if this is being called in every function or constructor.
     * @example
     * Logger.start();
     */
    public static void start(){
        startTime = startTime <> null ? startTime : timeStamp();
        processId = getProcessId();
    }

    /**
     * @function    getProcessId
     * @description Use to get the generated process Id of the transaction. Use it when there is another future call
     * @example
     * Logger.getProcessId();
     */
    public static String getProcessId(){
        return processId <> null ? processId : EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(startTime))));
    }

    /**
     * @function    setProcessId
     * @description Use to get the set process Id of the transaction. Use it when there is another future call
     * @example
     * String processId = Logger.getProcessId();
     * Logger.setProcessId(processId);
     */
    public static void setProcessId(String setProcessId){
        processId = setProcessId;
    }

    /**
     * @function    timeStamp
     * @description This function will return the currenct Unix timestamp
     * @return      Unix time stamp
     */
    static Long timeStamp() {
        return DateTime.now().getTime();
    }

    /**
     * @function    prettyMethod
     * @description To indent or clean the requested result
     * @param       method method name
     * @return      cleaned string name
     */
    static String prettyMethod(String method) {
        String result = (method == null) ? 'anonymous' : method;
        return (result.contains('init')) ? 'ctor' : result;
    }

    /**
     * @function    apiExceptionLog
     * @description use this function to log an exception record in System Log object with all performance metrics
     * @param       request API request
     * @param       response API response
     * @param       e Exception object
     * @param       integrationType type of integration inbound|outbound
     * @param       message custom message
     * @example
     * Logger.apiExceptionLog(requestObject, responseObject, exceptionObject, 'Inbound', 'custom message');
     */
    static void apiExceptionLog(String request, String response, Exception e, String integrationType, String message, String type){
        try{
            Map<String,String> parameterMap = parameters(e, request, response, String.valueOf(timeStamp()));
            parameterMap.put('integrationType',integrationType);
            parameterMap.put('customMessage', message);
            checkFutureLog(type, null, parameterMap, getAllLimits());
        }catch(Exception ex) {
            exception(ex);
        }
    }

    /**
     * @function    parameters
     * @description Shorthand of parameters(Exception e, String request, String response, String customMessage)
     * @param       e ExceptionObject
     * @param       endTime time when execution is ended
     * @return      Map<String,String>
     */
    static Map<String,String> parameters(Exception e, String endTime){
        return parameters (e,null,null,null, endTime);
    }

    /**
     * @function    parameters
     * @description Shorthand of parameters(Exception e, String request, String response, String customMessage)
     * @param       e ExceptionObject
     * @param       customMessage add custom message
     * @param       endTime time when execution is ended
     * @return      Map<String,String>
     */
    static Map<String,String> parameters(Exception e, String customMessage, String endTime){
        return parameters(e, customMessage, null, null, endTime);
    }

    /**
     * @function    parameters
     * @description Shorthand of parameters(Exception e, String request, String response, String customMessage)
     * @param       e ExceptionObject
     * @param       request API request
     * @param       response API response
     * @param       endTime time when execution is ended
     * @return      Map<String,String>
     */
    static Map<String,String> parameters(Exception e, String request, String response, String endTime){
        return parameters (e, null, request, response, endTime);
    }

    /**
     * @function    parameters
     * @description This function is used to capture all parameters required to create System Log records
     * @param       e ExceptionObject
     * @param       request API request
     * @param       response API response
     * @param       customMessage add custom message
     * @param       endTime time when execution is ended
     * @return      Map<String,String>
     */
    static Map<String,String> parameters(Exception e, String customMessage, String request, String response, String endTime){
        return new Map<String,String> {
                   'cause' => String.valueOf(e.getCause()),
                   'lineNumber' => String.valueOf(e.getLineNumber()),
                   'message' => e.getMessage(),
                   'stackTrace' => e.getStackTraceString(),
                   'exceptionType' => e.getTypeName(),
                   'processId' => processId,
                   'startTime' => String.valueOf(startTime),
                   'customMessage' => customMessage,
                   'request' => request,
                   'response' => response,
                   'endTime' => endTime
        };
    }

    /**
     * @function    getAllLimits
     * @description This function is used to capture all System limits required to create System Log records
     * @return      Map<String,Integer>
     */
    static Map<String, Integer> getAllLimits(){
        return dontProcess() ? new Map<String, Integer> {
                   'cpuTime' => Limits.getCpuTime(),
                   'heapSize' => Limits.getHeapSize(),
                   'dmlStatements' => Limits.getDmlStatements(),
                   'dmlRows' => Limits.getDMLRows(),
                   'queries' => Limits.getQueries(),
                   'queryRows' => Limits.getQueryRows(),
                   'aggregateQueries' => Limits.getAggregateQueries(),
                   'callouts' => Limits.getCallouts(),
                   'soslQueries' => Limits.getSoslQueries(),
                   'queryLocatorRows' => Limits.getQueryLocatorRows()
        } : null;
    }

    /**
     * @function    createLog
     * @description This function is used to create log/exceptions in Salesforce.
     * @param       recordTypeName use to add recordType Name of System Log record as per the type of log record
     * @param       recordId Add Salesforce record Id if there is any
     * @param       parameters use this Map to add all parameters like request/response, stack trace, log message, etc.
     * @param       limitsMap This is the Map of all limits we want to calculate for a Apex unit(function(s), constructor) component
     */
    static void createLog(String recordTypeName, String recordId, Map<String,String> parameters, Map<String,Integer> limitsMap){
        logRecord = new Log__c();
        List<Attachment> requestResponseAttachmentList = new List<Attachment>();
        logRecord.User__c = UserInfo.getUserId();
        logRecord.Type__c = recordTypeName;
        logRecord.Record_ID__c = recordId;
        logRecord.TransactionId__c = parameters.get('processId');
        if(parameters.get('request') <> null) {
            if(parameters.get('request').length() < 131073) {
                logRecord.Request__c = parameters.get('request');
            }else if(parameters.get('request').length() > 131072) {
                logRecord.Request__c = 'Please check the attachment.';
            }
            if(parameters.get('integrationType') <> null) {
                logRecord.IntegrationType__c = parameters.get('integrationType');
                if(logRecord.IntegrationType__c.equalsIgnoreCase('Inbound')) {
                    API_Processor.RallyRestRequest request = (API_Processor.RallyRestRequest)JSON.deserializeStrict(parameters.get('request'), API_Processor.RallyRestRequest.class);
                    logRecord.serviceName__c = request <> null ? request.serviceName : null;

                }else if(logRecord.IntegrationType__c.equalsIgnoreCase('Outbound')) {
                    API_Processor.RallyHttpRequest request = (API_Processor.RallyHttpRequest)JSON.deserializeStrict(parameters.get('request'), API_Processor.RallyHttpRequest.class);
                    logRecord.serviceName__c = request <> null ? request.serviceName : null;
                }
            }
            if(parameters.get('response') <> null) {
                if(parameters.get('response').length() < 131073) {
                    logRecord.Response__c = parameters.get('response');
                }else if(parameters.get('response').length() > 131072) {
                    logRecord.Response__c = 'Please check the attachment.';
                }
                API_Processor.RallyRestResponse response = (API_Processor.RallyRestResponse)JSON.deserializeStrict(parameters.get('response'), API_Processor.RallyRestResponse.class);
                if(response <> null) {
                    parameters.put('message',response.responseInfo.message);
                    logRecord.APIResponseCode__c = response.responseInfo.statusCode;
                }
            }
        }
        populateLocation(logRecord, parameters.get('stackTrace'));
        logRecord.Message__c = String.isBlank(parameters.get('customMessage')) ? parameters.get('message') : parameters.get('customMessage');
        if(limitsMap <> null) {
            logRecord.HeapSize__c = limitsMap.get('heapSize');
            logRecord.CPUTime__c = limitsMap.get('cpuTime');
            logRecord.aggregateQueries__c = limitsMap.get('aggregateQueries');
            logRecord.DMLRows__c = limitsMap.get('dmlRows');
            logRecord.DMLStatements__c = limitsMap.get('dmlStatements');
            logRecord.QueryRows__c = limitsMap.get('queryRows');
            logRecord.Queries__c = limitsMap.get('queries');
            logRecord.Callouts__c = limitsMap.get('callouts');
            logRecord.SOSLQueries__c = limitsMap.get('soslQueries');
            logRecord.QueryLocatorRows__c = limitsMap.get('queryLocatorRows');
        }
        if(parameters.get('endTime') <> null && parameters.get('startTime') <> null) {
            Long startTime = Long.valueOf(parameters.get('startTime'));
            Long endTime = Long.valueOf(parameters.get('endTime'));
            logRecord.StartTime__c = DateTime.newInstance (startTime).formatLong();
            logRecord.EndTime__c = DateTime.newInstance (endTime).formatLong();
            logRecord.TimeTaken__c = endTime - startTime;
        }
        insert logRecord;
        if(parameters.get('request') <> null && parameters.get('request').length() > 131072) {
            requestResponseAttachmentList.add(createAttachment(logRecord.Id,'request', parameters.get('request')));
        }
        if(parameters.get('response') <> null && parameters.get('response').length() > 131072) {
            requestResponseAttachmentList.add(createAttachment(logRecord.Id,'response', parameters.get('response')));
        }
        if(!requestResponseAttachmentList.isEmpty()) {
            insert requestResponseAttachmentList;
        }
    }

    /**
     * @function
     * @description Create attachment only if the size of request and response exceed from 131072
     */
    static Attachment createAttachment(String parentId, String name, String body){
        Attachment attachmentRecord = new Attachment();
        attachmentRecord.ParentId = parentId;
        attachmentRecord.Name = name + '.json';
        attachmentRecord.Body = Blob.valueOf(body);
        return attachmentRecord;
    }

    /**
     * @function    createFutureLog
     * @description This function is used to create log/exceptions in Salesforce with async process.
     * @param       recordTypeName use to add recordType Name of System Log record as per the type of log record
     * @param       recordId Add Salesforce record Id if there is any
     * @param       parameters use this Map to add all parameters like request/response, stack trace, log message, etc.
     * @param       limitsMap This is the Map of all limits we want to calculate for a Apex unit(function(s), constructor) component
     */
    @future(callout = false)
    static void createFutureLog(String recordTypeName, String recordId, Map<String,String> parameters, Map<String,Integer> limitsMap){
        createLog(recordTypeName, recordId, parameters, limitsMap);
    }

    /**
     * @function    checkFutureLog
     * @description This function will check is the logs should be created in syncronous or async way.
     * @param       recordTypeName use to add recordType Name of System Log record as per the type of log record
     * @param       recordId Add Salesforce record Id if there is any
     * @param       parameters use this Map to add all parameters like request/response, stack trace, log message, etc.
     * @param       limitsMap This is the Map of all limits we want to calculate for a Apex unit(function(s), constructor) component
     */
    static void checkFutureLog(String recordTypeName, String recordId, Map<String,String> parameters, Map<String,Integer> limitsMap){
        if(futureLog) {
            createFutureLog(recordTypeName, recordId, parameters, limitsMap);
        }else{
            createLog(recordTypeName, recordId, parameters, limitsMap);
        }
    }

    /**
     * @function    populateLocation
     * @description This is used to add the location of exception or log from where we have called
     * @param       logEvent use to add recordType Name of System Log record as per the type of log record
     * @param       stackTrace Add Salesforce record Id if there is any
     */
    static void populateLocation(Log__c logEvent, String stackTrace) {
        logEvent.StackTrace__c = stackTrace;
        for(String line : logEvent.StackTrace__c.split('\n')) {
            Matcher matcher = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$').matcher(line);
            if(matcher.find() && !line.startsWith('Class.' + Logger.class.getName() + '.')) {
                logEvent.ClassName__c = matcher.group(1);
                logEvent.Method__c = prettyMethod(matcher.group(2));
                logEvent.LineNumber__c = Integer.valueOf(matcher.group(4));
                return;
            }
        }
    }
    /**
     * @function    dontProcess
     * @description This function is used to block for creating log records only. This will be running from custom Metadata
     * @return      Map<String,Integer>
     */
    static Boolean dontProcess(){
        // TODO Add logic to run the Logger only for configured components
        return true;
    }
    /**
     * @function    log
     * @description Use to create an log record in System Log object for debugging purpose only
     * @param       recordId add recordId if applicable
     * @param       message Add a custom message you want to display on record
     * @example
     * Logger.exception(recordId, 'Your custom error message');
     */
    public static void log(String recordId, String message){
        try{
            if(dontProcess()) {
                DmlException e = new DmlException();
                String context = Trigger.isExecuting ? Trigger.isBefore ? Trigger.isInsert ? 'Before Insert' : Trigger.isUpdate ? 'Before Update' : Trigger.isDelete ? 'Before Delete' : 'Log' : Trigger.isAfter ? Trigger.isInsert ? 'After Insert' : Trigger.isUpdate ? 'After Update' : Trigger.isDelete ? 'After Delete' : Trigger.isUndelete ? 'After Undelete' : 'Log' : 'Log' : 'Log';
                checkFutureLog(context,recordId, parameters(e, message, String.valueOf(timeStamp())), getAllLimits());
            }
        }catch(Exception ex) {
            exception(ex);
        }
    }
    
    /**
     * @function    stop
     * @description Use this function when you want to capture all information about any performance/log/exceptions.
     *              You can treat this as a breakpoint.
     * @example
     * Logger.stop();
     */
    public static void stop(){
        try{
            if(dontProcess()) {
                DmlException e = new DmlException();
                String context = Trigger.isExecuting ? Trigger.isBefore ? Trigger.isInsert ? 'Before Insert' : Trigger.isUpdate ? 'Before Update' : Trigger.isDelete ? 'Before Delete' : 'Log' : Trigger.isAfter ? Trigger.isInsert ? 'After Insert' : Trigger.isUpdate ? 'After Update' : Trigger.isDelete ? 'After Delete' : Trigger.isUndelete ? 'After Undelete' : 'Log' : 'Log' : 'Log';
                checkFutureLog(context,null,parameters(e, 'Logs', String.valueOf(timeStamp())), getAllLimits());
            }
        }catch(Exception ex) {
            exception(ex);
        }
    }
}