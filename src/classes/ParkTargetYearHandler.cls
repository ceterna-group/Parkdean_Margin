public class ParkTargetYearHandler {
    
  public static void resetStockAUM(List<Park_Target_Year__c> targets) {
    // get all the park ids for the targets
    Set<Id> parkIds = new Set<Id>();
    for (Integer t = 0; t < targets.size(); t++) {
      String parkId = targets[t].Park__c;
      if (parkId != null) parkIds.add(parkId);
    }
    // get all the stock in those parks
    List<Product2> stock = [
      SELECT Id
      FROM Product2
      WHERE Park__c IN :parkIds
    ];
    // 'update' the stock to send it through the trigger (StockTrigger)
    update stock;
  }

}