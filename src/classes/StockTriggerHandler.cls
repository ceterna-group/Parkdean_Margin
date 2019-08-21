/**********************************************************************************************
* @Author:      Ronan Williams
* @Date:     20/08/2019
* @Description: StockTrigger directly calls StockTriggerHandler, which has the before update/insert logic
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/

public without sharing class StockTriggerHandler  {

  // after stock are inserted
  public static void beforeInsert(List<Product2> newMap) {

    // calculate min aum
    setAUM(newMap);
  }

  // after stock are updated
  public static void beforeUpdate(Map<Id,Product2> newMap,  Map<Id,Product2> oldMap) {
    // calculate min aum
    List<Product2> updateProduct2s = new List<Product2>();

    for (Product2 product : newMap.values()) {
      if ((product.Unit_Type__c != oldMap.get(product.Id).Unit_Type__c)
              || (product.SIV__c != oldMap.get(product.Id).SIV__c)
              || (product.Width__c != oldMap.get(product.Id).Width__c)
              || (product.Double_Glazing__c != oldMap.get(product.Id).Double_Glazing__c)
              || (product.Central_Heating__c != oldMap.get(product.Id).Central_Heating__c)
              || (product.Park__c != oldMap.get(product.Id).Park__c)) {
        updateProduct2s.add(product);
      }
    }
    setAUM(updateProduct2s);
  }

  /**********************************************************************************************
* @Author:      Ronan Williams
* @Date:     21/08/2019
* @Description: get the bandings from target years, categories, parkIds and stockIds and set the AUM based on those fields
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/

  public static void setAUM(List<Product2> stocks) {

    // get ids from stock
    Set<Id> stockParkIds = new Set<Id>();
    for (Product2 stock : stocks) {
      stockParkIds.add(stock.Park__c);
    }

    // get parks and target years from stock ids
    List<Park__c> parks = [SELECT Id, Name,
    (SELECT Id, Name, Year__c, Caravan_NB_AUM__c, Caravan_PX_AUM__c,
            Lodge_NB_AUM__c, Lodge_PX_AUM__c, Banding__c
    FROM Park_Targets__r WHERE Is_this_years_record__c = true)
    FROM Park__c
    WHERE Id IN :stockParkIds];

    // map park id to target year
    Map<String, Park_Target_Year__c> mapParkToTarget = new Map<String, Park_Target_Year__c>();
    // map park id to banding id
    Map<String, String> mapParkToBanding = new Map<String, String>();

    // get bandings from target years
    Set<Id> targetBandingIds = new Set<Id>();
    for (Park__c park : parks) {
      if (park.Park_Targets__r != null && park.Park_Targets__r.size() > 0) {
        mapParkToTarget.put(park.Id, park.Park_Targets__r[0]);
        String bandingId = park.Park_Targets__r[0].Banding__c;
        if (bandingId != null) {
          mapParkToBanding.put(park.Id, bandingId);
          targetBandingIds.add(bandingId);
        }
      }
    }

    // get bandings and their categories
    List<Banding__c> bandings = [SELECT Id, Name,
    (SELECT Id, Name, NB_AUM_Flex__c, PX_AUM_Flex__c,
            Lodge_NB_AUM_Flex__c, Lodge_PX_AUM_Flex__c, Category__c,
            Unit_Type__c
    FROM Banding_Categories__r)
    FROM Banding__c
    WHERE Id IN :targetBandingIds];

    // map banding id to banding categories
    Map<String, List<Banding_Category__c>> mapBandingToCategories = new Map<String, List<Banding_Category__c>>();
    for (Integer b = 0; b < bandings.size(); b++) {
      if (bandings[b].Banding_Categories__r != null && bandings[b].Banding_Categories__r.size() > 0) {
        mapBandingToCategories.put(bandings[b].Id, bandings[b].Banding_Categories__r);
      }
    }

    // for each stock item, check it's park's target and related banding categories
    for (Product2 stock : stocks) {
      String parkId = stock.Park__c;
      String stockType = stock.Unit_Type__c;
      String stockCategory = stock.Banding_Category__c;

      // if at any point we don't have these values we don't do anything with the stock record
      if (parkId != null) {
        // get target for the stock's park
        Park_Target_Year__c target = mapParkToTarget.get(parkId);
        if (target != null) {
          // get categories for the stock's park's banding
          String bandingId = mapParkToBanding.get(parkId);
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
            if (matchCategories.size() > 0) {
              Banding_Category__c match = matchCategories[0];

              // if we find a match
              if (stockType == 'Static' || stockType == 'Lodge') {
                String typeName = stockType == 'Static' ? 'Caravan' : 'Lodge';
                Decimal targetNB = (Decimal) target.get(typeName + '_NB_AUM__c');
                Decimal targetPX = (Decimal) target.get(typeName + '_PX_AUM__c');
                Decimal flexPX = (Decimal) match.get('PX_AUM_Flex__c') / 100;
                Decimal flexNB = (Decimal) match.get('NB_AUM_Flex__c') / 100;

                // only set if we have both vars
                if (targetNB != null && flexNB != null) {
                  stock.Min_AUM__c = targetNB * flexNB;
                }
                if (targetPX != null && flexPX != null) {
                  stock.PX_Min_AUM__c = targetPX * flexPX;
                }
              }
              // otherwise reset the AUMs
            } else {
              stock.Min_AUM__c = 0;
              stock.PX_Min_AUM__c = 0;
            }
          }
        }
      }
    }
  }
}