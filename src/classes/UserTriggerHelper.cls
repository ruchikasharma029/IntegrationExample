public with sharing class UserTriggerHelper {
	@future
	public static void deleteUserClickRecords(list<id> userDeactivatedIdList ){
		list<user> userDeactivatedList = [Select (select id from Click_Records__r) from user where id in:userDeactivatedIdList];
		list<Click_Record__c> recordsToBeDeleted = new list<Click_Record__c>();
		for(user deactivatedUser : userDeactivatedList){
			recordsToBeDeleted.addAll(deactivatedUser.Click_Records__r);
		}
		
		system.debug('recordsToBeDeleted  ' + recordsToBeDeleted);
		if(recordsToBeDeleted != null && recordsToBeDeleted.size()>0){
			delete recordsToBeDeleted;
		}
	}
}