@isTest
public class UserClickRecordTests {

	public static UserRole role{
		get{
			if (role == null){
				//insert user Role
				role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
				insert role;
			}				
			return role;			
	
		}set;}
	
	public static User thisUser{
		get{
			if (thisUser == null){
				//get current user
				thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
			}				
			return thisUser;			
	
		}set;}
	
    static testMethod void TestUserDeactivateBulk() {
        System.runAs (thisUser) {
		//insert new User
			User newuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,LastName = 'last',Email = 'test@test.com',Username = 'bulktest@test.com',
									CompanyName = 'TEST',Title = 'title',Alias = 'alias',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',
									LocaleSidKey = 'en_US',UserRoleId = role.Id,isActive=true);
			insert newuser;
			
			list<Click_Record__c> recordsToBeDeleted = new list<Click_Record__c>();
			//insert bulk Click Records
			for(integer i=0; i<9990;i++){
				Click_Record__c testrecord = new Click_Record__c(user__c = newuser.id);
	             recordsToBeDeleted.add(testrecord);
			}
			insert recordsToBeDeleted;
		list<Click_Record__c> clickRecordsbefore = [select id from Click_Record__c where user__c =: newuser.id];
		system.assert(clickRecordsbefore.size()==9990,'9999 Click records should be there');
		test.starttest();
			//deactivate user
			newuser.isActive = false;
			update newuser;
		test.stopTest();
		//future method runs after stop test
			list<Click_Record__c> clickRecordsAfter= [select id from Click_Record__c where user__c =: newuser.id];
			system.assert(clickRecordsAfter.size()==0,'no Click records should be there');
        }
		
    	
    }
    static testMethod void TestMultipleUserDeactivate() {
        System.runAs (thisUser) {
			//insert multiple Users
			list<user> userList = new list<user>();
			User newuser1 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,LastName = 'last',Email = 'test@test.com',Username = 'bulktest1@test.com',
									CompanyName = 'TEST',Title = 'title',Alias = 'alias',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',
									LocaleSidKey = 'en_US',UserRoleId = role.Id,isActive=true);
			userList.add(newuser1);
			
			//insert User
			User newuser2 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,LastName = 'last',Email = 'test@test.com',Username = 'bulktest2@test.com',
									CompanyName = 'TEST',Title = 'title',Alias = 'alias',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',
									LocaleSidKey = 'en_US',UserRoleId = role.Id,isActive=true);
			userList.add(newuser2);
			insert userList;
			list<Click_Record__c> recordsToBeDeleted = new list<Click_Record__c>();
			//insert bulk Click Records
				Click_Record__c testrecord1 = new Click_Record__c(user__c = newuser1.id);
	            recordsToBeDeleted.add(testrecord1);
				Click_Record__c testrecord2 = new Click_Record__c(user__c = newuser2.id);
	            recordsToBeDeleted.add(testrecord2);
	        insert recordsToBeDeleted;
		
			list<Click_Record__c> clickRecordsbefore = [SELECT id from Click_Record__c WHERE user__c =: newuser1.id OR user__c =: newuser2.id];
			system.assert(clickRecordsbefore.size()==2,'2 Click records should be there');
			test.starttest();
				//deactivate users
				for(user u:userList){
				u.isActive = false;}
				
				update userList;
			test.stopTest();
			//future method runs after stop test
			list<Click_Record__c> clickRecordsAfter=  [SELECT id from Click_Record__c WHERE user__c =: newuser1.id OR user__c =: newuser2.id];
			system.assert(clickRecordsAfter.size()==0,'no Click records should be there');
        }
    	
    }
    static testMethod void TestUserClickRecordController() {
        PageReference pageRef = Page.UserClickRecord;
        Test.setCurrentPage(pageRef);
        UserClickRecordsController controller = new UserClickRecordsController();
    	Test.startTest();
    		controller.recordUserClick();
    		list<Click_Record__c> clickRecordsAfter= [select id from Click_Record__c where user__c =: thisUser.id];
    		system.assert(clickRecordsAfter.size() == 1);
    		controller.recordUserClick();
    		clickRecordsAfter= [select id from Click_Record__c where user__c = :thisUser.id];
    		system.assert(clickRecordsAfter.size() == 2);
    	Test.StopTest();
    }


}