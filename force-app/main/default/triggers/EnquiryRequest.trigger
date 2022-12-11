trigger EnquiryRequest on Enquiry__c (after insert) {

    List<Enquiry__c> enquiries = new List<Enquiry__c>();

    for(Enquiry__c enq : Trigger.new){

        String body = EnquiryFormService.buildEnquiryFormBody(enq);
        EnquiryFormService.doPost(body);

        enquiries.add(enq);
    }

    EnquiryFormService.createLead(enquiries);
}