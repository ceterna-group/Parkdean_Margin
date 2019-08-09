trigger BandingCategoryTrigger on Banding_Category__c (before insert, before update) {
    
  BandingCategoryTriggerHandler handler = new BandingCategoryTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.beforeInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isBefore) {
    handler.beforeUpdate();
  }

}