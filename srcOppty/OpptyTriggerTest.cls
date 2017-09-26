@isTest
public class OpptyTriggerTest {
	private static string currCode;
    private static account testAccount1;
    private static account testAccount2;
    private static List<DatedConversionRate> convRates;
    private static void setUpData(){
        
    	// Get the first active, non-USD currency code
        currCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsoCode <> 'USD' limit 1].IsoCode;
        
        // Get a list of conversion rates for this currency code
        convRates = [Select ConversionRate,IsoCode,StartDate FROM DatedConversionRate WHERE IsoCode = :currCode ORDER BY StartDate DESC];
        System.assertNotEquals(convRates.size(), 0); 
        testAccount1 = new Account(Name = 'Test Acount 1', CurrencyIsoCode  = 'USD',rating = 'Hot');
        testAccount2 = new Account(Name = 'Test Acount 2', CurrencyIsoCode  = 'USD',rating = 'Hot');
        insert new list<account> {testAccount1, testAccount2};
        
    }
    
    public static testmethod void testInsertOppty(){
    	setUpData();
        opportunity oppty = new opportunity(Name = 'Oppty for Test Account 1',CurrencyIsoCode = currCode,Amount = 100,
                                            accountId =  testAccount1.id, stageName = 'Closed Won', CloseDate = system.today() );
        insert oppty;
        account acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        decimal convertedAmount = oppty.Amount/convRates[1].ConversionRate;
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                      ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate );
        
    }

    public static testmethod void testUpdatetOpptyToClosedWon(){
    	setUpData();
        opportunity oppty = new opportunity(Name = 'Oppty for Test Account 1',CurrencyIsoCode = currCode,Amount = 100,
                                            accountId = testAccount1.id, stageName = 'Prospecting', CloseDate = system.today() );
        insert oppty;
        account acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        opportunity opptyAfterInsert = [select id , Amount, Amount_USD__c  from opportunity where id =:oppty.Id];
        decimal convertedAmount = oppty.Amount/convRates[1].ConversionRate;
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c != convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                      ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate );
        system.assert(opptyAfterInsert.Amount == opptyAfterInsert.Amount_USD__c );
        oppty.StageName = 'Closed Won';
        update oppty;
        acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                      ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate );
    }
    public static testmethod void testUpdatetOpptyChangeAccount(){
    	setUpData();
        opportunity oppty = new opportunity(Name = 'Oppty for Test Account 1',CurrencyIsoCode = currCode,Amount = 100,
                                            accountId = testAccount1.id, StageName = 'Closed Won', CloseDate = system.today() );
        insert oppty;
        account acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        opportunity opptyAfterInsert = [select id , Amount, Amount_USD__c  from opportunity where id =:oppty.Id];
        decimal convertedAmount = oppty.Amount/convRates[1].ConversionRate;
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                      ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate );
        system.assert(opptyAfterInsert.Amount == opptyAfterInsert.Amount_USD__c );
        oppty.AccountId = testAccount2.Id;
        update oppty;
        map <id,account> acctAfterOpptyupdate = new map<id,account> ([select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount2.Id OR id =:testAccount1.Id]);
        system.assert(acctAfterOpptyupdate.get(testAccount1.id).Total_Value_of_Won_Opps_derived__c != convertedAmount);
        system.assert(acctAfterOpptyupdate.get(testAccount2.id).Total_Value_of_Won_Opps_derived__c == convertedAmount);
    }
    public static testmethod void testUpdatetOpptyChangeAmount(){
    	setUpData();
        opportunity oppty = new opportunity(Name = 'Oppty for Test Account 1',CurrencyIsoCode = currCode,Amount = 100,
                                            accountId = testAccount1.id, StageName = 'Closed Won', CloseDate = system.today() );
        insert oppty;
        account acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        opportunity opptyAfterInsert = [select id , Amount, Amount_USD__c  from opportunity where id =:oppty.Id];
        decimal convertedAmount = oppty.Amount/convRates[1].ConversionRate;
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == convertedAmount);
        system.assert(opptyAfterInsert.Amount == opptyAfterInsert.Amount_USD__c );
		test.startTest();
            oppty.Amount = 200;
            update oppty;
            convertedAmount = oppty.Amount/convRates[1].ConversionRate;
            account acctAfterOpptyUpdate = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
            opportunity opptyAfterUpdate = [select id , Amount, Amount_USD__c  from opportunity where id =:oppty.Id];
            system.assert(acctAfterOpptyUpdate.Total_Value_of_Won_Opps_derived__c == convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                          ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate  );
            system.assert(opptyAfterInsert.Amount == opptyAfterInsert.Amount_USD__c );
		test.stopTest();
    }

    public static testmethod void testUpdatetOpptyFromClosedWon(){
    	setUpData();
        opportunity oppty = new opportunity(Name = 'Oppty for Test Account 1',CurrencyIsoCode = currCode,Amount = 100,
                                            accountId = testAccount1.id, stageName = 'Closed Won', CloseDate = system.today() );
        insert oppty;
        account acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        opportunity opptyAfterInsert = [select id , Amount, Amount_USD__c  from opportunity where id =:oppty.Id];
        decimal convertedAmount = oppty.Amount/convRates[1].ConversionRate;
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                      ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate );
        system.assert(opptyAfterInsert.Amount == opptyAfterInsert.Amount_USD__c );
        oppty.StageName = 'Prospecting';
        update oppty;
        acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c != convertedAmount, acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c + 
                      ' ******** ' + oppty.Amount +' **** ' + convRates[1].ConversionRate );
    }
    public static testmethod void testInsertOpptyBulk(){
    	setUpData();
        list<opportunity> opptyList = new list<opportunity> ();
        for(integer i = 0; i<100 ; i++){
        	opportunity oppty = new opportunity(Name = 'Oppty for Test Account ' + i,CurrencyIsoCode = currCode,Amount = 1,
                                				accountId = testAccount1.id, stageName = 'Closed Won', CloseDate = system.today() );
        	opptyList.add(oppty);
        	
        }
        insert opptyList;
        account acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        decimal convertedAmount = 100/convRates[1].ConversionRate;
        //system.assert(1==2, 'acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c  ' + acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c); 
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == convertedAmount );
        for(opportunity oppty:  opptyList){
        	oppty.StageName = 'Prospecting';
        }
        update opptyList;
        acctAfterOpptyInsert = [select id , Total_Value_of_Won_Opps_derived__c  from account where id =:testAccount1.Id];
        system.assert(acctAfterOpptyInsert.Total_Value_of_Won_Opps_derived__c == 0 );
    }
}
