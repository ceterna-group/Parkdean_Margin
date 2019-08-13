/**
 * Created by ronanwilliams on 2019-08-08.
 */

public with sharing class ApprovalPanelController {


    @AuraEnabled
    public static Object getApprovalStatusApex(String recordId){

        Map<String,Object> responseValues = new Map<String,Object>();

        Quote quote = [SELECT Id, Approval_Status__c, OwnerId, Park__r.Regional_Sales_Manager__c,
                              Park__r.Regional_Director__c
                       FROM Quote WHERE Id = '0Q01j0000009n2BCAQ'];
        responseValues.put('_quote',quote);
        responseValues.put('_requiresApproval',quote.Approval_Status__c == 'Pending');
        responseValues.put('_currentUser',(UserInfo.getUserId() == quote.OwnerId));
        responseValues.put('_userRole',([SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()].UserRole.Name == 'System Administrators'));
        responseValues.put('_approver',UserInfo.getUserId() == quote.Park__r.Regional_Sales_Manager__c || UserInfo.getUserId() == quote.Park__r.Regional_Director__c);

        return responseValues;
    }

    @AuraEnabled
    public static Boolean approveRecordApex(String recordId, Boolean approved, String comment) {

        update new Quote(
            Id                                  = recordId,
            Approval_Status__c                  = approved ? 'Approved' : 'Rejected',
            Approval_Responded_By__c            = UserInfo.getUserId(),
            Latest_Approval_Response_Time__c    = Datetime.now(),
            Latest_Rejection_Comment__c         = comment
        );

        List<Margin_Notification__c> notification = [SELECT Id FROM Margin_Notification__c
                                                    WHERE Sales_Example__c = :recordId
                                                    AND Void__c = FALSE];

        if (!notification.isEmpty()){
            notification[0].Approval_Response_Time__c   = Datetime.now();
            notification[0].Approval_Responded_By__c    = UserInfo.getUserId();
            notification[0].Status__c                   = approved ? 'Approved' : 'Rejected';
            notification[0].Comment__c                  = comment;
            update notification;
        }

        return true;
    }

}