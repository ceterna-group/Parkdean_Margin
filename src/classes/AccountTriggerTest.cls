@IsTest
public class AccountTriggerTest {
    
  @IsTest
  public static void testAccountTrigger() {
    // check the trigger is called, we test the logic through the AccountHandler
    Account a = new Account();
    a.Name = 'Test Insert';
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      insert a;
      a.Name = 'Test Update';
      update a;
    Test.stopTest();
    System.assertNotEquals(null, a.Id);
  }

}