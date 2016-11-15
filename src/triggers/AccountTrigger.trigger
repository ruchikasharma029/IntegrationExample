trigger AccountTrigger on Account (after insert) {
	
	AccountTriggerHandler.actionAfterInsert(JSON.serialize(trigger.new) );

}