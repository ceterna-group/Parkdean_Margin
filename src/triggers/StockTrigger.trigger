trigger StockTrigger on Product2 (before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            StockTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            StockTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
        }
    }
}