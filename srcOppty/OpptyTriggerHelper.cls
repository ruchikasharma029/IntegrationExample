{\rtf1\ansi\ansicpg1252\cocoartf1504\cocoasubrtf830
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 public with sharing class OpptyTriggerHelper \{\
    /* This is the helper class to convert opportunity Amounts in currency other that corporate currency\
	and calculate total sum amount of all Closed Won opportunities for each account */\
	private static Map<ID,DatedConversionRate> dcrIdToDcrMap; \
    private list<opportunity> opptyListForAmtSubtracted = new list<opportunity>();\
    private list<opportunity> opptyListForAmtAdded = new list<opportunity>();\
   \
    //This mathod adds closed won opportunities' amounts sum to account field Total Value of Won Opportunities\
    public void addAmountForAccount(list<opportunity> opptyList,map<id,account> mOpptyAcct)\{\
        set<Account> acctToBeUpdated = new set<Account>();\
        for(opportunity o: opptyList)\{\
            if(mOpptyAcct.containsKey(o.AccountId))\{\
                decimal amount = convertToCorporateCurrency(o.CurrencyIsoCode, o.Amount_USD__c, o.CloseDate);\
                if(mOpptyAcct.get(o.AccountId).Total_Value_of_Won_Opps_derived__c == null)\{\
                    mOpptyAcct.get(o.AccountId).Total_Value_of_Won_Opps_derived__c = Amount;\
                \}else\{\
                    mOpptyAcct.get(o.AccountId).Total_Value_of_Won_Opps_derived__c += Amount;\
                \}\
            	acctToBeUpdated.add(mOpptyAcct.get(o.AccountId));\
            \}\
        \}        \
        if(!acctToBeUpdated.isEmpty())\{\
        	update mOpptyAcct.values();\
        \}\
    \}\
    \
\
    //This mathod subtracts opportunities' amounts from account field Total Value of Won Opportunities for the \
    //opportunities whose stsge eother chnaged from closed won to other or changed account\
    public void subtractAmountForAccount(list<opportunity> opptyList,map<id,account> mOpptyAcct)\{\
        set<Account> acctToBeUpdated = new set<Account>();\
        for(opportunity o: opptyList)\{\
            if(mOpptyAcct.containsKey(o.AccountId))\{\
                if(mOpptyAcct.get(o.AccountId).Total_Value_of_Won_Opps_derived__c != null)\{\
                    mOpptyAcct.get(o.AccountId).Total_Value_of_Won_Opps_derived__c = mOpptyAcct.get(o.AccountId).Total_Value_of_Won_Opps_derived__c - convertToCorporateCurrency(o.CurrencyIsoCode , o.Amount_USD__c, o.CloseDate);\
                    acctToBeUpdated.add(mOpptyAcct.get(o.AccountId));\
                \}\
            \}\
        \}        \
        if(!acctToBeUpdated.isEmpty())\{\
        	update mOpptyAcct.values();\
        \}\
    \}\
    \
    //this method calculate the converted amount from opportunity's currencey to corporate currency from dated exchange rates \
    //base on opportunity closed date \
	public static Decimal convertToCorporateCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) \{\
        Decimal result;\
        if (currencyIso == null || currencyVal == null) \{\
            return null;\
        \}else \{\
            if (dcrIdToDcrMap == null)\{              // build the map only once for life of the transaoction\
                dcrIdToDcrMap = new Map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);\
            \}\
            for (DatedConversionRate dcr: dcrIdToDcrMap.values()) \{\
                if (dcr.isoCode != currencyIso) \{// look for a match in table against input currency\
                	continue; \}  \
                if (currencyDate > dcr.startDate && (currencyDate <= dcr.nextStartDate ))\{  \
                    result =  currencyVal / dcr.conversionRate;\
                	break;\
                \}else\{\
                    continue;   // not in the range of effective dates\
                \}  \
            \}\
        \}\
        return result;\
    \}\
    //this method is called by trigger to handle Opportunity Amount USD field and Account total sum amount of all Closed Won opportunities \
    public void updateUSDAmountsAndRollup(list<opportunity> opptyList,map<id,opportunity> mOldOpptyVal,set<id> acctIdSet)\{\
        map<id,Account> mOpptyAcct = new map<id, Account>([select id, Total_Value_of_Won_Opps_derived__c from Account where id in :acctIdSet ]);\
        for(opportunity newOppty: opptyList)\{\
        	//update Amount USD field with Amount field\
            newOppty.Amount_USD__c = newOppty.Amount;\
            if(trigger.isInsert && newOppty.StageName == 'Closed Won')\{\
            	opptyListForAmtAdded.add(newOppty);    \
            \}else if(trigger.isUpdate)\{\
            	opportunity oldOppty = mOldOpptyVal.get(newOppty.Id);                \
                //if old StageName was not 'Closed Won' and new StageName is 'Closed Won'\
                if(oldOppty.StageName != 'Closed Won' && newOppty.StageName == 'Closed Won')\{\
                    opptyListForAmtAdded.add(newOppty);\
                \}else if(oldOppty.StageName == 'Closed Won' && newOppty.StageName != 'Closed Won' )\{\
                 //if old StageName was 'Closed Won' and new StageName is not 'Closed Won'\
               	opptyListForAmtSubtracted.add(oldOppty);  \
                \}\
                //if Amount or Account change on opportunity\
                else if((oldOppty.AccountId != newOppty.AccountId) ||(oldOppty.Amount != newOppty.Amount) && newOppty.StageName == 'Closed Won' )\{\
                    opptyListForAmtAdded.add(newOppty);\
                	opptyListForAmtSubtracted.add(oldOppty);  \
                \}\
            \}\
            \
        \}\
        \
        if(!opptyListForAmtAdded.isEmpty())\{\
            addAmountForAccount(opptyListForAmtAdded,mOpptyAcct);\
        \}\
        if(!opptyListForAmtSubtracted.isEmpty())\{\
            subtractAmountForAccount(opptyListForAmtSubtracted,mOpptyAcct);\
        \}\
        \
    \}\
\}}