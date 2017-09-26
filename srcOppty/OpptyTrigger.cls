{\rtf1\ansi\ansicpg1252\cocoartf1504\cocoasubrtf830
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 trigger OpptyTrigger on Opportunity (before Insert,before Update) \{\
    OpptyTriggerHelper helper = new OpptyTriggerHelper();\
    list<opportunity> opptyWithAmounts = new list<opportunity>();\
    map<id,opportunity> oldOpptyWithAmounts = new map<id,opportunity>();\
    set<Id> mAccountSet = new set<Id>();\
    for(opportunity oppty: trigger.new)\{\
        if(oppty.amount != null && Oppty.CloseDate != null)\{\
			opptyWithAmounts.add(oppty); \
            mAccountSet.add(oppty.AccountId);\
            if(trigger.isUpdate)\{\
            	opportunity oldOppty = trigger.oldMap.get(oppty.Id);\
            	oldOpptyWithAmounts.put(oppty.id,oldOppty);    \
            	mAccountSet.add(oldOppty.AccountId);\
            \}\
        \}\
    \}\
    if(!opptyWithAmounts.isEmpty())\{\
        helper.updateUSDAmountsAndRollup(opptyWithAmounts,oldOpptyWithAmounts,mAccountSet);\
    \}\
\}}