trigger OpptyTrigger on Opportunity (before Insert,before Update) {
    OpptyTriggerHelper helper = new OpptyTriggerHelper();
    list<opportunity> opptyWithAmounts = new list<opportunity>();
    map<id,opportunity> oldOpptyWithAmounts = new map<id,opportunity>();
    set<Id> mAccountSet = new set<Id>();
    for(opportunity oppty: trigger.new){
        if(oppty.amount != null && Oppty.CloseDate != null){
			opptyWithAmounts.add(oppty); 
            mAccountSet.add(oppty.AccountId);
            if(trigger.isUpdate){
            	opportunity oldOppty = trigger.oldMap.get(oppty.Id);
            	oldOpptyWithAmounts.put(oppty.id,oldOppty);    
            	mAccountSet.add(oldOppty.AccountId);
            }
        }
    }
    if(!opptyWithAmounts.isEmpty()){
        helper.updateUSDAmountsAndRollup(opptyWithAmounts,oldOpptyWithAmounts,mAccountSet);
    }
}
