/*
 * @class StockTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler 
 *   class. You must keep the extends attribute for this class to work.
 */
public without sharing class StockTriggerHandler extends TriggerHandler {
    
  // after stock are inserted
  public override void beforeInsert() {
    // calculate min aum
    StockHandler.setAUM(Trigger.new);
  }
    
  // after stock are updated
  public override void beforeUpdate() {

    // Unit_Type__c, SIV__c, Width__c, Double_Glazing__c, Central_Heating__c, Park__c


    // calculate min aum
    StockHandler.setAUM(Trigger.new);
  }

}