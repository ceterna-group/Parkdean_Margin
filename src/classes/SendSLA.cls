public class SendSLA {
    
  @AuraEnabled
  public static String[] checkQuote(String quoteId) {
    Quote quote = getQuote(quoteId);
    List<String> responses = new List<String>();

//    String res = 'Ready';
    if (quote.Status == 'SLA pending with Wizard') responses.add('This Quote has already been sent to Wizard.');
    if (quote.Expected_handover_date__c == null) responses.add('You must set an expected handover date');
    if (quote.Record_type_formula__c != 'Private_Sale' && quote.Record_type_formula__c != 'Trade_Sale') {
      if (quote.Number_of_final_products__c == 0 || quote.Number_of_pitches_selected__c == 0) responses.add('You must set a final product and final pitch.');
    }
//    List<String> profiles = new List<String>{'New_Biz', 'Part_Ex_Current_owner', 'Part_Ex_New_Biz', 'Read_Only_New_Customer',
//            'Read_Only_Existing_Customer_Part_exchange', 'Read_Only_New_Customer_Part_Exchange_WITHOUT_BUTTONS'};
//    if (profiles.indexOf(quote.Record_type_formula__c) != -1 && quote.Approval_Status__c != 'Approved') {
//      if (quote.Margin_Amount__c < quote.Min_AUM__c) responses.add('Margin amount is less than the minimum AUM value and ' +
//              'has not been approved. Please speak to your Regional Sales Manager or Regional Director.');
//    }
    if (quote.Margin_Calculation_Record_types__c && !quote.Margin_Send_SLA__c) responses.add('You need Approval for this Sales example before you can send the SLA to wizard.');

    if (responses.isEmpty()){
      responses.add('Ready');
    }

    return responses;
  }
    
  @AuraEnabled
  public static String sendQuote(String quoteId) {
    return ODISLA.sendSLA(quoteId);
  }
    
  private static Quote getQuote(String quoteId) {
    Quote quote = [
      SELECT Id, Status, Expected_handover_date__c, Number_of_final_products__c, Number_of_pitches_selected__c,
              Record_type_formula__c, Margin_Send_SLA__c, Margin_Calculation_Record_types__c
      FROM Quote
      WHERE Id = :quoteId
      LIMIT 1
    ];
    return quote;
  }

}