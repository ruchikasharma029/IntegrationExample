public with sharing class UserClickRecordsController {
	public pagereference recordUserClick(){
		id userid = userinfo.getUserId();
		Click_Record__c clickRecord = new Click_Record__c(User__c = userid, Clicked_Date_Time__c = system.now());
		system.debug('clickRecord : ' + clickRecord);
		insert clickRecord;
		return null;
	
	}
}