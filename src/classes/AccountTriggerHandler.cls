public with sharing class AccountTriggerHandler {
	
	public class deserializeResponse{
      public String id;
      public String access_token;
    }
	public class SendAccountUsingRESTAPI {

		REST_Configuration__c config = REST_Configuration__c.getValues('Old_Org_Credentials');	   	
		private  String clientId ;
		private  String clientSecret ;
		private  String username ;
		private  String password ;
		public String ReturnAccessToken (SendAccountUsingRESTAPI acount){
		
			if(config != null){
				clientId = config.Client_Id__c;
				clientSecret = config.Client_Seceret__c;
				username = config.User_Name__c;
				password = config.password__c + config.Token__c;
			}
			String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
		
		    Http h = new Http();
		    HttpRequest req = new HttpRequest();
		    req.setBody(reqbody);
		    req.setMethod('POST');
		    req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
		    HttpResponse res = h.send(req);     
		 		system.debug('res:  '+ res.getbody());
		 		system.debug('status:  '+ res.getstatus());
		 		system.debug('status code :  '+ res.getStatusCode());
		    deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
		
		    return resp1.access_token;
		}	
	}
   

 @future(callout=true)
	public static void actionAfterInsert (string accountString){
      SendAccountUsingRESTAPI token = new SendAccountUsingRESTAPI();
      list<account> accounts = (List<Account>)JSON.deserialize(accountString,List<Account>.class);
      String accessToken;
      accessToken = token.ReturnAccessToken (token);
   
		if(accessToken != null){
	     	String endPoint = 'https://oldorg-dev-ed.my.salesforce.com/services/apexrest/AccountListView?name=';	
	      	Http h2 = new Http();
	      	HttpRequest req1 = new HttpRequest();
	      	req1.setHeader('Authorization','Bearer ' + accessToken);
	      	req1.setHeader('Content-Type','application/x-www-form-urlencoded');
	      	req1.setHeader('accept','application/json');
		    req1.setEndpoint(endPoint );
			if(accounts.size() == 1){
				string n= EncodingUtil.urlEncode(accounts[0].name, 'UTF-8');
				endpoint +=n;
		 		system.debug('endpoint:  '+ endpoint);
				
		    	req1.setEndpoint(endPoint );
		      	req1.setMethod('GET');
		      	HttpResponse res1 = h2.send(req1); 
		      
		 		system.debug('res1:  '+ res1.getbody());
		 		system.debug('status:  '+ res1.getstatus());
		 		system.debug('status code :  '+ res1.getStatusCode());
		     	if(res1.getbody() != null && res1.getbody() != ''){
		      		list<account> accountReturned = (List<Account>)JSON.deserialize(res1.getbody(),List<Account>.class);
		      		accounts[0].ext_id__c= accountReturned[0].id;
		      	
		      	}
		      
		      	update accounts[0];
		      }else{
		     	list<string> accountnames = new list<string>();
		     	for(account acc:accounts){
		     		accountnames.add(acc.name);
		     	}
		     	
		     	string accountnameString = string.join(accountnames,',');
		      	req1.setMethod('POST');
		      	req1.setbody('payLoad='+accountnameString);
		      	HttpResponse res1 = h2.send(req1); 
		      
		     	if(res1.getbody() != null && res1.getbody() != ''){
		      		list<account> accountReturned = (List<Account>)JSON.deserialize(res1.getbody(),List<Account>.class);
		      		map<id, account> accountMap = new map<id, account>(accountReturned);
		      		for(account acc:accounts){
		      			if(accountMap.containsKey(acc.id)){
		      				acc.ext_id__c= accountMap.get(acc.id).id;
		      			}
		      		
		      		}
		      	
		      	}
		      
		      
		      
		      }

	   }
   }
}