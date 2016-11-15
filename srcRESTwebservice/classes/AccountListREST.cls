@RestResource(urlMapping='/AccountListView/*')
global with sharing class AccountListREST {



	@HttpGet
	global static List<Account> getAccounts() {

 		system.debug('Got here');
        RestRequest req = RestContext.request;
 		RestResponse res = RestContext.response;
        String param = req.params.get('name'); 
	    string query;
	    string AccountName;
        if(param != null){
	   		AccountName = EncodingUtil.urlDecode(param, 'UTF-8');
        
        }
        
       system.debug('AccountName ' + AccountName); 
       system.debug('req ' + req); 
	    try {
	    	if(AccountName == null){
		 		query = 'Select ID, Name,phone,AccountNumber,Type,BillingStreet,BillingCity,BillingPostalCode,BillingCountry from Account limit 4000';
	    	}
	    	else{
		 		query = 'Select ID, Name,phone from Account where Name='+'\'' +AccountName +'\'' +'  Limit 1';

		    }	       
       system.debug('query ' + query); 
				list<account> accts = database.query(query); 
       system.debug('accts ' + accts); 
			    return accts;
	    } catch (exception e) {

	        return null;

	    }	   
	 }
	
	@HttpPost
	global static List<Account> getAccountsBulk() {

        RestRequest req = RestContext.request;
 		RestResponse res = RestContext.response;
	    string query;
	    list<string> strList = req.params.get('payLoad').split(',');
	    list<string> accountNameList = new list<string>();
	    for(string s:strList){
	        string sid = '\'' + string.valueof(s) + '\'';
	        accountNameList.add(sid);
	    }
	    try {
			query = 'Select ID, Name,phone from Account where Name IN  ' +accountNameList ;

			list<account> accts = database.query(query); 
			return accts;
	    } catch (exception e) {

	        return null;

	    }	   
	 }
	

}