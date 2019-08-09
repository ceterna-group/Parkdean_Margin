trigger ParkTargetYearTrigger on Park_Target_Year__c (before insert, before update) {
    
  ParkTargetYearTriggerHandler handler = new ParkTargetYearTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.beforeInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isBefore) {
    handler.beforeUpdate();
  }

}