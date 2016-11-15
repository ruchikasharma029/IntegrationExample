public without sharing class PointTrackerAccountViewExt {
    public final Point_Tracker_Account__c PTA;
	//private CustomIterable obj;
  	@testvisible private List<ExchangeOfferWrapper> ExchangeOfferList{get;set;}
  	public boolean ShowExchangeOfferBlock{get;set;}
   	public boolean booleanVal;
    public String RewardProgramSelectedOld ;
    private set<Id> SelectedElementSet;
    public String RewardProgramSelected { get
    {
    	if(RewardProgramSelected==null)
           RewardProgramSelected='All';
           return RewardProgramSelected;
    	}set;
	}
    public PointTrackerAccountViewExt(ApexPages.StandardController sc) {
        if (!Test.isRunningTest()){
        	sc.addFields(new List<String> {'Owner.Alias'});}
        PTA = (Point_Tracker_Account__c)sc.getRecord();
        ShowExchangeOfferBlock = false; 
        SelectedElementSet= new set<Id>();
        
    }
    public ApexPages.StandardSetController setcon {
        get {
            if(setcon == null) {
            	
				id PTAOwnerId = PTA.OwnerId;
				string Query = 'select id, name, From_Points__c, From_Point_Balance__r.Name, To_Points__c, To_Point_Balance__r.name, CreatedBy.Name, CreatedBy.Alias from Exchange_Offer__c ';
				string WhereClause = ' Where Accepted_By__c = null and CreatedById != :PTAOwnerId';
				if(RewardProgramSelected == 'All'){   
				} else{
		 			WhereClause	+= ' And (To_Point_Balance__r.Name =: RewardProgramSelected)';
				
				}   
				whereClause += ' Order By From_Points__c Limit 10000';     
            	
                setcon = new ApexPages.StandardSetController(Database.getQueryLocator(Query+WhereClause));
                // sets the number of records in each page set
                setcon.setPageSize(5);
            }
            return setcon;
        }
        set;
    }

	public class ExchangeOfferWrapper{
		public id ExchangeOfferId {get;set;}
	 	public boolean Selected{get;set;}
	 	public decimal PointsGained{get;set;}
	 	public String PointsGainedIn{get;set;}
	 	public decimal PointCost{get;set;}
	 	public String PointCostFrom{get;set;}
	 	public String MemberAlias{get;set;}
	 	
	 	
	 	ExchangeOfferWrapper(id ExchangeOfferId,boolean Selected,decimal PointsGained,String PointsGainedIn,decimal PointCost,String PointCostFrom, String MemberAlias ){
	 		this.ExchangeOfferId = ExchangeOfferId;
	 		this.PointsGained = PointsGained;
	 		this.PointsGainedIn = PointsGainedIn;
	 		this.MemberAlias = MemberAlias; 
	 		this.PointCost = PointCost;
	 		this.PointCostFrom = PointCostFrom;
	 		this.Selected = Selected; 
	 		
	 	}
	}
	
    public Decimal getRewardPointValue() {
    	
    	decimal RPV;
    	list<AggregateResult> PTAList = [Select Point_Tracker_Account__c, SUM(Cash_Value__c) cvSum from  Point_Balance__c group by Point_Tracker_Account__c having Point_Tracker_Account__c =:PTA.id ];
    	if(PTAList != null && PTAList.size()>0){
	    	RPV = (decimal)PTAList[0].get('cvSum');
	    	return RPV;}
    	else
    		return 0;
    }

    public pageReference CheckAccess(){
    	PageReference PointTrackerAccountViewPage = Page.PointTrackerAccountView;
    	PointTrackerAccountViewPage.setRedirect(true);
    	return PointTrackerAccountViewPage;    
    	return new PageReference('/'+PTA.id);
    }
	
	public list<SelectOption> RewardProgramsList{ 
		get{
			 RewardProgramsList = new list<SelectOption>();
			 list<Point_Balance__c> ExchangeOffers = [Select id, name from Point_Balance__c where Point_Tracker_Account__c =: PTA.id];
			 RewardProgramsList.add( new SelectOption('All','All'));
			 
			 for(Point_Balance__c eoff: ExchangeOffers){
				 RewardProgramsList.add( new SelectOption(eoff.name,eoff.name));
			 }
			return RewardProgramsList;
		}
		set ;
	}
	public void ExchangePointsAction(){
		
        setcon = null;
        SelectedElementSet = new set<Id>();
        ShowExchangeOfferBlock = true;
		
	 
	}

 	public list<ExchangeOfferWrapper> getExchangeOfferList(){
		ExchangeOfferList = new list<ExchangeOfferWrapper>();
        
        for(Exchange_Offer__c sObj: (List<Exchange_Offer__c>)setcon.getRecords()){
        	    boolean selectval;
        	    if(SelectedElementSet.contains(sObj.id)){
        	    	selectval= true;
        	    }else{
         	    	selectval= false;        	    
        	    }
        	    
	        	ExchangeOfferWrapper EW = new ExchangeOfferWrapper(sObj.id,selectval,sObj.From_Points__c,sObj.From_Point_Balance__r.Name,sObj.To_Points__c,sObj.To_Point_Balance__r.Name,sObj.CreatedBy.Alias);
	        	ExchangeOfferList.add(EW);
        	
        } 
        system.debug('ExchangeOfferList : '+ ExchangeOfferList.size());
        system.debug('RewardProgramSelected : '+ RewardProgramSelected);
        return ExchangeOfferList;
		
	 
	}

	public Boolean hasNext {
        get {
            return setcon.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return setcon.getHasPrevious();
        }
        set;
    }

    // returns the first page of records
     public void first() {
     	 
     	for(ExchangeOfferWrapper ew: ExchangeOfferList){
     		if(ew.selected){
     			SelectedElementSet.add(ew.ExchangeOfferId);
     		}else if(SelectedElementSet.contains(ew.ExchangeOfferId)){
     			SelectedElementSet.remove(ew.ExchangeOfferId);
     			
     		}
     	}
         setcon.first();
     }

     // returns the last page of records
     public void last() {
     	for(ExchangeOfferWrapper ew: ExchangeOfferList){
     		if(ew.selected){
     			SelectedElementSet.add(ew.ExchangeOfferId);
     		}else if(SelectedElementSet.contains(ew.ExchangeOfferId)){
     			SelectedElementSet.remove(ew.ExchangeOfferId);
     			
     		}
     	}
         setcon.last();
     }

     // returns the previous page of records
     public void previous() {
     	for(ExchangeOfferWrapper ew: ExchangeOfferList){
     		if(ew.selected){
     			SelectedElementSet.add(ew.ExchangeOfferId);
     		}else if(SelectedElementSet.contains(ew.ExchangeOfferId)){
     			SelectedElementSet.remove(ew.ExchangeOfferId);
     			
     		}
     	}
         setcon.previous();
     }

     // returns the next page of records
	 public void next() {
	 	for(ExchangeOfferWrapper ew: ExchangeOfferList){
	 		if(ew.selected){
	 			SelectedElementSet.add(ew.ExchangeOfferId);
	 		}else if(SelectedElementSet.contains(ew.ExchangeOfferId)){
	 			SelectedElementSet.remove(ew.ExchangeOfferId);
	 			
	 		}
	 	}
	 	//system.assert(1==2,'ExchangeOfferList before ' + ExchangeOfferList);
	     setcon.next(); 
	 }

	
	public pageReference AcceptOfferAction(){
	 	for(ExchangeOfferWrapper ew: ExchangeOfferList){
	 		if(ew.selected){
	 			SelectedElementSet.add(ew.ExchangeOfferId);
	 		}else if(SelectedElementSet.contains(ew.ExchangeOfferId)){
	 			SelectedElementSet.remove(ew.ExchangeOfferId);
	 			
	 		}
	 	}
	 	
	 	system.debug('ExchangeOfferList in action :  ' + ExchangeOfferList);
	 	system.debug('SelectedElementSet in action :  ' + SelectedElementSet);
    	if(SelectedElementSet == null || SelectedElementSet.size() <1 ){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No Exchange Offers are selected.'));
    		return null;
    	}else{
		 	map<id,Exchange_Offer__c> offerstoActupon = new map<id,Exchange_Offer__c>([select id, name, From_Points__c, From_Point_Balance__r.Name, From_Point_Balance__r.Point_Tracker_Account__c,To_Point_Balance__r.Point_Tracker_Account__c, To_Points__c, To_Point_Balance__r.name, CreatedBy.Name,From_Point_Balance__r.Balance__c,To_Point_Balance__r.Balance__c from Exchange_Offer__c where id in: SelectedElementSet]);
			map<string,decimal> pointBalanceTotalExchangepointsmap = new map<string,decimal>();

 		 	for(Exchange_Offer__c off: offerstoActupon.values()){
				if(!pointBalanceTotalExchangepointsmap.containskey(off.From_Point_Balance__r.Point_Tracker_Account__c)){
					if(off.From_Points__c != null){						
						pointBalanceTotalExchangepointsmap.put(string.valueOF(off.From_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.From_Point_Balance__c), off.From_Points__c);
					}
				}else{
					pointBalanceTotalExchangepointsmap.put(string.valueOF(off.From_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.From_Point_Balance__c),pointBalanceTotalExchangepointsmap.get(string.valueOF(off.From_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.From_Point_Balance__c)) + off.From_Points__c);				
				}
				if(!pointBalanceTotalExchangepointsmap.containskey(off.To_Point_Balance__r.Point_Tracker_Account__c)){
					if(off.To_Points__c != null){						
						pointBalanceTotalExchangepointsmap.put(string.valueOF(off.To_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.To_Point_Balance__c), off.To_Points__c);
					}
				}else{
					pointBalanceTotalExchangepointsmap.put(string.valueOF(off.To_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.To_Point_Balance__c),pointBalanceTotalExchangepointsmap.get(string.valueOF(off.To_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.To_Point_Balance__c)) + off.To_Points__c);				
				}
			}
	 		
	 		system.debug('pointBalanceTotalExchangepointsmap  :' + pointBalanceTotalExchangepointsmap);
	 		system.debug('offerstoActupon  :' + offerstoActupon);
			Savepoint sp = Database.setSavepoint();	 	
			boolean sawError = false;			
	 		try{
		 		for(Exchange_Offer__c off: offerstoActupon.values()){
	 				system.debug('off here  :' + off);
		 			if(pointBalanceTotalExchangepointsmap.get(string.valueOF(off.From_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.From_Point_Balance__c))> off.From_Point_Balance__r.Balance__c || 
		 				pointBalanceTotalExchangepointsmap.get(string.valueOF(off.To_Point_Balance__r.Point_Tracker_Account__c)+string.valueOF(off.To_Point_Balance__c))> off.To_Point_Balance__r.Balance__c){
			    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There are not enough points available in Rewards Program to complete your exchange.'));
		 				sawError = true;
		 				break;
			    		return null;
		 			}else{
						list<Transaction__c> transactionToBeInsertedList = new list<Transaction__c>();
		 				Id recType = string.valueOf(Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Exchange').getRecordTypeId());
		 				Transaction__c transaction1 = new Transaction__c();
		 				transaction1.Name ='Transaction 1';
		 				transaction1.RecordTypeId = recType;
		 				transaction1.Point_Tracker_Account__c = off.From_Point_Balance__r.Point_Tracker_Account__c;
		 				transaction1.Points__c = off.From_Points__c * -1;
		 				transaction1.Point_Balance__c = off.From_Point_Balance__c;
		 				transactionToBeInsertedList.add(transaction1);
		 			
		 				Transaction__c transaction2 = new Transaction__c();
		 				transaction2.Name ='Transaction 2';
		 				transaction2.RecordTypeId = recType;
		 				transaction2.Points__c = off.From_Points__c;
		 				transaction2.Point_Tracker_Account__c = off.To_Point_Balance__r.Point_Tracker_Account__c;
		 				transaction2.Point_Balance__c = off.To_Point_Balance__c;
		 				transactionToBeInsertedList.add(transaction2);
	
		 				Transaction__c transaction3 = new Transaction__c();
		 				transaction3.Name ='Transaction 3';
		 				transaction3.RecordTypeId = recType;
		 				transaction3.Points__c = off.To_Points__c * -1;
		 				transaction3.Point_Tracker_Account__c = off.To_Point_Balance__r.Point_Tracker_Account__c;
		 				transaction3.Point_Balance__c = off.To_Point_Balance__c;
		 				transactionToBeInsertedList.add(transaction3);
		 			
		 				Transaction__c transaction4 = new Transaction__c();
		 				transaction4.Name ='Transaction 4';
		 				transaction4.RecordTypeId = recType;
		 				transaction4.Points__c = off.To_Points__c;
		 				transaction4.Point_Tracker_Account__c = off.From_Point_Balance__r.Point_Tracker_Account__c;
		 				transaction4.Point_Balance__c = off.From_Point_Balance__c;
		 				transactionToBeInsertedList.add(transaction4);
		 				
	 					system.debug('transactionToBeInsertedList  :' + transactionToBeInsertedList);
	 		
		 				insert transactionToBeInsertedList;
		 				off.Accepted_By__c = PTA.Owner.Alias;
			 				
		 			}
	 			}
 				if(!sawError){
 					update offerstoActupon.values();
		    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Selected Offer(s) Successfully Accepted.'));
		    		setcon = null;
 				}
		 		}catch(exception e){
					Database.rollback(sp);
					system.debug('e  :' + e.getmessage());
					
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Fatal Error Occured and the exchang(s) is not complete. Please try again.'));
 					return new pageReference('/' + PTA.id);
		 				
		 		}
	 		return null;
	 	}
	 	
	}


	 public void Cancel() {
	 
        ShowExchangeOfferBlock = false;
	 
	 }
    
	 public Pagereference Save() {
	 
		if(PTA.Name == null || PTA.Name=='' ){
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Point Tracker Account Name Cannot be blank.'));
	    	return null;
		
		}Else {
			update PTA;
 	 		return new pageReference('/' + PTA.id);
		} 
		 	 	
	 
	 }
    
}