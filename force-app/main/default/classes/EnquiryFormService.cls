public with sharing class EnquiryFormService {
    //These are the variables for parsing data from lwc components
    public static final String ENQUIRY_TYPE = 'enquiryType';
    public static final String FIRST_NAME = 'firstName';
    public static final String LAST_NAME = 'lastName';
    public static final String EMAIL = 'email';
    public static final String COUNTRY = 'country';
    public static final String PHONE = 'phone';
    public static final String HOLIDAY_TYPE = 'holidayType';
    public static final String NUMBER_OF_ADULTS = 'numberOfAdults';
    public static final String NUMBER_OF_CHILDREN = 'numberOfChildren';
    public static final String ARRIVAL_DATE = 'arrivalDate';
    public static final String DEPATURE_DATE = 'depatureDate';
    public static final String COMMENTS = 'comments';
    public static final String ACCOUNT = 'account';

    //This is the method to save data from lwc to the org
    @AuraEnabled
    public static Map<String,Object> saveEnquiry(Map<String,Object> data){
        try {

             Enquiry__c enquiry = new Enquiry__c();
             enquiry.Enquiry_Type__c = data.get(ENQUIRY_TYPE).toString();
             enquiry.First_Name__c = data.get(FIRST_NAME).toString();
             enquiry.Last_Name__c = data.get(LAST_NAME).toString();
             enquiry.Email__c = data.get(EMAIL).toString();
             enquiry.Country__c = data.get(COUNTRY).toString();
             enquiry.Phone__c = data.get(PHONE).toString();
             enquiry.Holiday_Type__c = data.get(HOLIDAY_TYPE).toString();
             enquiry.Number_of_Adults__c = Decimal.valueOf(data.get(NUMBER_OF_ADULTS).toString());
             enquiry.Number_of_Children__c = Decimal.valueOf(data.get(NUMBER_OF_CHILDREN).toString());
             enquiry.Arrival_Date__c = Date.parse(data.get(ARRIVAL_DATE).toString());
             enquiry.Departure_Date__c = Date.parse(data.get(DEPATURE_DATE).toString());
             enquiry.Comments__c = data.get(COMMENTS).toString();
             enquiry.Account__c = data.get(ACCOUNT).toString();

            insert enquiry;
            Map<String,Object> response = new Map<String,Object>();
            response.put('Id',enquiry.Id);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //This is the method to get the picklist of accounts
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getAccounts(){
        
        List<Map<String,Object>> results = new List<Map<String,Object>>();

        try {

            List<Account> accounts = [SELECT Id,Name FROM Account WITH SECURITY_ENFORCED];

            // for extracting values so that they work for the ComboBox on LWC
            for(Account account : accounts){
                Map<String,Object> res = new Map<String,Object>();
                res.put('label',account.Name);
                res.put('value',account.Id);

                results.add(res);
            }

            return results;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    //This is a method to create lead records 
    public static void createLead(List<Enquiry__c> enquiries){

        List<Lead> leads = new List<Lead>();

        for(Enquiry__c enquiry : enquiries){

            Lead lead = new Lead();
            lead.LastName = enquiry.Last_Name__c +' '+enquiry.First_Name__c;
            lead.Email = enquiry.Email__c;  
            lead.Status = 'Open - Not Contacted';
            lead.Company = enquiry.Account__c;

            leads.add(lead);
        }

        insert leads;

    }
    
    //This converts enquiry into a request body
    public static String buildEnquiryFormBody(Enquiry__c enquiry)
    {
        EnquiryFormData form = new EnquiryFormData();
        form.website_reference_number = enquiry.Enquiry_Number__c ;
        form.first_name = enquiry.First_Name__c ;
        form.last_name = enquiry.Last_Name__c ;
        form.email = enquiry.Email__c ;
        form.contact_number = enquiry.Phone__c ;
        form.country = enquiry.Country__c ;
        form.arrival_date = enquiry.Arrival_Date__c ;
        form.depature_date = enquiry.Departure_Date__c ;
        form.adults = enquiry.Number_of_Adults__c ;
        form.children = enquiry.Number_of_Children__c ;
        form.comments = enquiry.Comments__c ;
        form.ed_website = '72';
        form.ed_passkey = 'devpass' ;

        return (String) JSON.serializePretty(form,false);
        
    }

    //This is the method to Make a request
    @future(callout=true)
    public static void doPost(String body){

        try 
        {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint('https://eddy.rhinoafrica.com/submit');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setBody(body);
            
            HttpResponse res = http.send(req);
            String responseBody = res.getBody();

            ResponseEnquiry responseToEnquiry = (ResponseEnquiry) JSON.deserialize(responseBody, ResponseEnquiry.class);
            System.debug(responseToEnquiry);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }

    //This is the class to deserialize the response body 
    Class ResponseEnquiry{
        public String message;
        public String status;
        public Boolean error;

    }

    //This is the class that helps to serialize the request body 
    class EnquiryFormData {
        public String website_reference_number;
        public String first_name;
        public String last_name;
        public String email;
        public String contact_number;
        public String country;
        public Date arrival_date;
        public Date depature_date;
        public Decimal adults;
        public Decimal children;
        public String comments;
        public String ed_website;
        public String ed_passkey;
    }

}

