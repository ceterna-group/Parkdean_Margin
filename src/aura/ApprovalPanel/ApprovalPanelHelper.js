/**
 * Created by ronanwilliams on 2019-08-08.
 */

({
    updateRecord : function($C,approved) {
        var approveRecordResult = $C.get('c.approveRecordApex');
        approveRecordResult.setParams({
            recordId : $C.get('v.recordId'),
            approved : approved,
            comment : $C.get('v.comment')
        });
        approveRecordResult.setCallback(this, function(response){
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                $C.set('v.render',false);
                $C.set('v.componentUpdate',true);
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type": "success"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(approveRecordResult);
    }


});