trigger StockTrigger on Product2 (before insert, before update) {
    
  StockTriggerHandler handler = new StockTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.beforeInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isBefore) {
    handler.beforeUpdate();
  }

}