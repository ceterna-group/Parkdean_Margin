/*
 * @class ParkTargetYearTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler 
 *   class. You must keep the extends attribute for this class to work.
 */
public without sharing class ParkTargetYearTriggerHandler extends TriggerHandler {
    
  // before targets are inserted
  public override void beforeInsert() {
    // get related stock and then calculate min aum
    ParkTargetYearHandler.resetStockAUM(Trigger.new);
  }
    
  // before targets are updated
  public override void beforeUpdate() {
    // get related stock and then calculate min aum
    ParkTargetYearHandler.resetStockAUM(Trigger.new);
  }

}