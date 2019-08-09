public class BandingCategoryHandler {
    
  public static void resetStockAUM(List<Banding_Category__c> categories) {
    // get all the bandings for these categories
    Set<Id> bandingIds = new Set<Id>();
    for (Integer c = 0; c < categories.size(); c++) {
      String bandingId = categories[c].Banding__c;
      if (bandingId != null) bandingIds.add(bandingId);
    }
    // get all the park targets with this banding
    List<Park_Target_Year__c> parkTargets = [
      SELECT Id, Park__c
      FROM Park_Target_Year__c
      WHERE Banding__c IN :bandingIds
    ];
    // get all stock in those parks
    Set<Id> parkIds = new Set<Id>();
    for (Integer p = 0; p < parkTargets.size(); p++) {
      String parkId = parkTargets[p].Park__c;
      if (parkId != null) parkIds.add(parkId);
    }
    List<Product2> stock = [
      SELECT Id
      FROM Product2
      WHERE Park__c IN :parkIds
    ];
    // 'update' the stock to send it through the trigger (StockTrigger)
    update stock;
  }

}