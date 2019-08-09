/**********************************************************************************************
* @Author: Ceterna
* @Date:        
* @Description: Account custom trigger handler class that extends the TriggerHandler 
*   class. You must keep the extends attribute for this class to work.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
public with sharing class AccountTriggerHandler extends TriggerHandler {
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date: 22/07/2019       
  * @Description: Hook for the 'beforeInsert' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  public override void beforeInsert() {
    // set park ids from name multiselect
    AccountHandler.setParkIds(Trigger.new);
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:       
  * @Description: Hook for the 'afterInsert' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  public override void afterInsert() {
    // send changes to ODI, only if not ODI
    String ODI = [SELECT Id FROM User WHERE Name = 'ODI' LIMIT 1].Id;
    if (UserInfo.getUserId() != ODI) {
      AccountHandler.postChanges(Trigger.new, 'CREATE');
    }
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date: 22/07/2019       
  * @Description: Hook for the 'beforeUpdate' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  public override void beforeUpdate() {
    // set park ids from name multiselect
    AccountHandler.setParkIds(Trigger.new);
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:       
  * @Description: Hook for the 'afterUpdate' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
  public override void afterUpdate() {
    // send changes to ODI, only if not ODI
    String ODI = [SELECT Id FROM User WHERE Name = 'ODI' LIMIT 1].Id;
    if (UserInfo.getUserId() != ODI) {
      AccountHandler.postChanges(Trigger.new, 'UPDATE');
    }
  }

}