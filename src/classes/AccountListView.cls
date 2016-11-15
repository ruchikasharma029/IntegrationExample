public with sharing class AccountListviewExt {
	
   //Login Domain May be test, prerellogin.pre
	    String LOGIN_DOMAIN = 'www';
	    public String pwd{get;set;}
	    public String userName{get;set;}
	    public List<Account> accounts{get;set;}
	    public List<Account> getAcc(){
	    	if(setcon != null){
	    		return (List<Account>)setcon.getRecords();
	    	}else{
	    		return null;
	    	}
	    	//return acc;
	    
	    }

	 

	    public ApexPages.StandardSetController setcon {
	        get {
	            if(setcon == null && accounts!= null) {
	            	
	            	
	                setcon = new ApexPages.StandardSetController(accounts);
	                // sets the number of records in each page set
	                setcon.setPageSize(25);
	            }
	            return setcon;
	        }
	        set;
	    }
	 

	    public void fetch()

	    {
			setcon=null;
			accounts = new list<Account>();

	        try{

		        //-----------------------------------
	
		        // Login via SOAP/XML web service api
	
		        //-----------------------------------
	
		        HttpRequest request = new HttpRequest();
	
		        request.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/22.0');
	
		        request.setMethod('POST');
	
		        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
	
		        request.setHeader('SOAPAction', '""');
	
		        //not escaping username and password because we're setting those variables above
	
		        //in other words, this line "trusts" the lines above
	
	
		        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + pwd+ '</password></login></Body></Envelope>');
	
		        Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
	
		          .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
	
		          .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
	
		          .getChildElement('result', 'urn:partner.soap.sforce.com');
	
		 
	
		        //-------------------------------
	
		        // Grab session id and server url
	
		        //--------------------------------
	
		        final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
	
		        final String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
	
		 
	
		        //----------------------------------
	
		        // Load first 10 accounts via REST API
	
		        //---------------------------------
	
		        final PageReference theUrl = new PageReference(SERVER_URL + '/services/apexrest/AccountListView');
		        
	
				if(SESSION_ID != null){
			        request = new HttpRequest();
			        request.setEndpoint(theUrl.getUrl());
			        request.setMethod('GET');
			        request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
		        	Http http = new Http();
			 		HTTPResponse resp = http.send(request);
			 		
		
		
			 		string body = resp.getBody();
		
			 		system.debug('resp:  '+ body);
			 		system.debug('status:  '+ resp.getstatus());
			 		system.debug('status code :  '+ resp.getStatusCode());
			 		accounts = (List<Account>)JSON.deserialize(body,List<Account>.class);
				}
				if(accounts == null || accounts.size() == 0){
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'No Records found in this Org.'));
				}	 		
	        }

	        catch(Exception e)

	        {

	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Some Error Occurred ' + e.getmessage()));

	        }

	 

	    }

	public Boolean hasNext {
        get {
        	if(setcon != null)
            	return setcon.getHasNext();
            else
            	return false;
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
        	if(setcon != null)
            	return setcon.getHasPrevious();
            else
            	return false;
        }
        set;
    }

    // returns the first page of records
     public void first() {
     	 
         setcon.first();
     }

     // returns the last page of records
     public void last() {
         setcon.last();
     }

     // returns the previous page of records
     public void previous() {
         setcon.previous();
     }

     // returns the next page of records
	 public void next() {
	     setcon.next(); 
	 }

	public  pageReference goBack() {
		Schema.DescribeSObjectResult result = Account.SObjectType.getDescribe();
		PageReference pageRef = new PageReference('/' + result.getKeyPrefix());
		pageRef.setRedirect(true);

  		return pageRef;
	 }
}