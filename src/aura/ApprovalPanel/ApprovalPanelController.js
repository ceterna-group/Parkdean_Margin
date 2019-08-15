/**
 * Created by ronanwilliams on 2019-08-08.
 */

({
    doInit : function($C,$E,$H){

        var approvalInfo = $C.get('c.getApprovalStatusApex');
        approvalInfo.setParams({ recordId : $C.get('v.recordId')});
        approvalInfo.setCallback(this, function(response){
           if (response.getState() === 'SUCCESS'){

               var data     = response.getReturnValue();


               console.log('requires approval ' +  data._requiresApproval);
               console.log('relevant user  ' + (data._currentUser || data._userRole));

               var quote    = data._quote;
               var render   = data._requiresApproval && (data._currentUser || data._userRole);
               var approver = data._userRole || data._approver;
               $C.set('v.render',render);
               $C.set('v.approver',approver);
               $C.set('v.quote',quote);
               $C.set('v.rejecting',false);
               $C.set('v.comment','');
               $C.set('v.initialised',true);
           }
        });
        $A.enqueueAction(approvalInfo);
    },
    approveRecord : function($C,$E,$H) {
        $H.updateRecord($C,true);
    },
    rejectRecord : function($C,$E,$H) {
        if ($C.get('v.comment')){
            $H.updateRecord($C,false);
        } else {
            $C.set('v.rejecting',true);
        }
    },
    recordUpdated : function($C,$E,$H){

        if ($C.get('v.initialised') && $C.get('v.record.Approval_Status__c') !== $C.get('v.quote.Approval_Status__c')){
                $A.enqueueAction($C.get('c.doInit'));
        }
    }
});