public class StockHandler {
    
  public static void setAUM(List<Product2> stock) {
    System.debug('START');
    System.debug(stock);
    // get ids from stock
    Set<Id> stockParkIds = new Set<Id>();
    for (Integer s = 0; s < stock.size(); s++) {
      String parkId = stock[s].Park__c;
      if (parkId != null) stockParkIds.add(parkId);
    }
    // get parks and target years from stock ids
    List<Park__c> parks = [
      SELECT Id, Name,
        (SELECT Id, Name, Year__c, Caravan_NB_AUM__c, Caravan_PX_AUM__c,
           Lodge_NB_AUM__c, Lodge_PX_AUM__c, Banding__c
         FROM Park_Targets__r WHERE Is_this_years_record__c = true)
      FROM Park__c
      WHERE Id IN :stockParkIds
    ];
    // map park id to target year
    Map<String, Park_Target_Year__c> mapParkToTarget = new Map<String, Park_Target_Year__c>();
    // map park id to banding id
    Map<String, String> mapParkToBanding = new Map<String, String>();
    // get bandings from target years
    Set<Id> targetBandingIds = new Set<Id>();
    for (Integer p = 0; p < parks.size(); p++) {
      if (parks[p].Park_Targets__r != null && parks[p].Park_Targets__r.size() > 0) {
        mapParkToTarget.put(parks[p].Id, parks[p].Park_Targets__r[0]);
        String bandingId = parks[p].Park_Targets__r[0].Banding__c;
        if (bandingId != null) {
          mapParkToBanding.put(parks[p].Id, bandingId);
          targetBandingIds.add(bandingId);   
        }
      } 
    }
    // get bandings and their categories
    List<Banding__c> bandings = [
      SELECT Id, Name, 
        (SELECT Id, Name, Caravan_NB_AUM_Flex__c, Caravan_PX_AUM_Flex__c,
           Lodge_NB_AUM_Flex__c, Lodge_PX_AUM_Flex__c, Category__c,
           Unit_Type__c
         FROM Banding_Categories__r)
      FROM Banding__c
      WHERE Id IN :targetBandingIds
    ];
    // map banding id to banding categories
    Map<String, List<Banding_Category__c>> mapBandingToCategories = new Map<String, List<Banding_Category__c>>();
    for (Integer b = 0; b < bandings.size(); b++) {
      if (bandings[b].Banding_Categories__r != null && bandings[b].Banding_Categories__r.size() > 0) {
        mapBandingToCategories.put(bandings[b].Id, bandings[b].Banding_Categories__r);
      }   
    }
    System.debug(mapParkToTarget);
    System.debug(mapParkToBanding);
    System.debug(mapBandingToCategories);
    // for each stock item, check it's park's target and related banding categories
    for (Integer s = 0; s < stock.size(); s++) {
      String parkId = stock[s].Park__c;  
      String stockType = stock[s].Unit_Type__c;
      String stockCategory = stock[s].Banding_Category__c;
      
      // if at any point we don't have these values we don't do anything with the stock record
      if (parkId != null) {
        // get target for the stock's park
        Park_Target_Year__c target = mapParkToTarget.get(parkId);
        System.debug(target);
        if (target != null) {
          // get categories for the stock's park's banding
          String bandingId = mapParkToBanding.get(parkId);
          System.debug(bandingId);
          if (bandingId != null) {
            List<Banding_Category__c> categories = mapBandingToCategories.get(bandingId);
            // check if a category matches, and take that match
            List<Banding_Category__c> matchCategories = new List<Banding_Category__c>();
            for (Integer c = 0; c < categories.size(); c++) {
              // check unit type & category
              if (categories[c].Unit_Type__c == stockType && categories[c].Category__c == stockCategory) {
                matchCategories.add(categories[c]);
              }
            }
            // as long as we have at least one match
            System.debug(matchCategories);
            if (matchCategories.size() > 0) {
              Banding_Category__c match = matchCategories[0]; 
              // if we find a match
              if (stockType == 'Static' || stockType == 'Lodge') {
                String typeName = stockType == 'Static' ? 'Caravan' : 'Lodge';
                Decimal targetNB = (Decimal) target.get(typeName + '_NB_AUM__c');
                Decimal flexNB = (Decimal) match.get(typeName + '_NB_AUM_Flex__c') / 100;
                Decimal targetPX = (Decimal) target.get(typeName + '_PX_AUM__c');
                Decimal flexPX = (Decimal) match.get(typeName + '_PX_AUM_Flex__c') / 100; 
                // only set if we have both vars
                if (targetNB != null && flexNB != null) {
                  stock[s].Min_AUM__c = targetNB * flexNB;
                }
                if (targetPX != null && flexPX != null) {
                  stock[s].PX_Min_AUM__c = targetPX * flexPX;
                }
              }
            // otherwise reset the AUMs
            } else {
              stock[s].Min_AUM__c = 0;
              stock[s].PX_Min_AUM__c = 0;
            }
          }
        }
      }
    }
  }

}