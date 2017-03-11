trigger UserTrigger on User (after update) {
	
	list<Id> userDeactivatedList = new list<Id>();
	UserTriggerHelper helperClass = new UserTriggerHelper();
	for(user changedUser:Trigger.new){
		user oldUser = trigger.oldmap.get(changedUser.id);
		if(	oldUser.IsActive  && !changedUser.IsActive){
			userDeactivatedList.add(changedUser.id);
		}
		
		if(userDeactivatedList != null && userDeactivatedList.size()>0){
			UserTriggerHelper.deleteUserClickRecords(userDeactivatedList);
		}
	}
}