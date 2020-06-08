/**
 * @Component Name      API_Interface
 * @Created Date        May 11, 2020
 * @Description         API_Interface class is an interface for Rest API to write business logic. This interface contains the signature of three crucial functions preProcess, process and postProcess which can be differently in new service classes .
 * @Test Class          
 * @Author              Gaurav Trivedi
 * @Group
 * @Last Modified By: Gaurav Trivedi
 * @Last Modified On: 6/3/2020, 1:40:29 PM
 * @Modification Log
 * **********************************************************************************************************************
 *										Modification Log
 * **********************************************************************************************************************
 *  Name				|	Version		|		Date		|					Discription
 * **********************************************************************************************************************
 *	Gaurav Trivedi      |       1.0     |	May 11, 2020	|	Initial Draft
 * **********************************************************************************************************************
 */
public interface API_Interface {
    void preProcess(API_Processor.RallyRestRequest request);
    API_Processor.RallyRestResponse processRequest();
    void postProcess();
}