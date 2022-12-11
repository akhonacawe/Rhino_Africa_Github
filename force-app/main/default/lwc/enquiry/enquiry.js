import { LightningElement , wire, track} from 'lwc';
import saveEnquiry from '@salesforce/apex/EnquiryFormService.saveEnquiry';
import getAccounts from '@salesforce/apex/EnquiryFormService.getAccounts';
import { NavigationMixin } from 'lightning/navigation';

export default class Enquiry extends NavigationMixin(LightningElement) {

    formInvalid = true;

    enquiryForm = {
        enquiryType : null,
        firstName : null,
        lastName : null,
        email : null,
        country : null,
        phone : null,
        holidayType : null,
        numberOfAdults : null,
        numberOfChildren : null,
        arrivalDate : null,
        depatureDate : null,
        comments : null,
        account : null
    }

    @wire(getAccounts)
    wiredAccounts

    get enquiryTypeOptions() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Telephone', value: 'Telephone' },
            { label: 'Personal Contact', value: 'Personal Contact' },
        ];
    }

    handleEnquiryTypeChange(event) {
        this.enquiryForm.enquiryType = event.detail.value;
        this.isFormValid();
    }

    get holidayTypeOptions() {
        return [
            { label: 'Value', value: 'Value' },
            { label: 'Standard', value: 'Standard' },
            { label: 'Luxury', value: 'Luxury' },
        ];
    }

    handleHolidayTypeChange(event) {
        this.enquiryForm.holidayType = event.detail.value;
        this.isFormValid();
    }

    get countryOptions() {
        return [
            { label: 'Australia (Code: AU)', value: 'Australia (Code: AU)' },
            { label: 'United Kingdom (Code: GB)', value: 'United Kingdom (Code: GB)' },
            { label: 'United States of America (Code: US)', value: 'United States of America (Code: US)' },
        ];
    }

    handleCountryChange(event) {
        this.enquiryForm.country = event.detail.value;
        this.isFormValid();
    }

    handleFirstName(event){
        this.enquiryForm.firstName = event.detail.value;
        this.isFormValid();
    }

    handleLastName(event){
        this.enquiryForm.lastName = event.detail.value;
        this.isFormValid();
    }

    handleEmail(event){
        this.enquiryForm.email = event.detail.value;
        this.isFormValid();
    }

    handlePhone(event){
        this.enquiryForm.phone = event.detail.value;
        this.isFormValid();
    }

    handleNumberOfAdults(event){
        this.enquiryForm.numberOfAdults = event.detail.value;
        this.isFormValid();
    }

    handleNumberOfChildren(event){
        this.enquiryForm.numberOfChildren = event.detail.value;
        this.isFormValid();
    }

    handleArrivalDate(event){
        //Making the right format for date to match the org format
        let date = event.detail.value.replaceAll('-', '/').split("/");
        this.enquiryForm.arrivalDate = date[2]+'/'+date[1]+'/'+date[0];
        this.isFormValid();
    }

    handleDepatureDate(event){
        let date = event.detail.value.replaceAll('-', '/').split("/");
        this.enquiryForm.depatureDate = date[2]+'/'+date[1]+'/'+date[0];
        this.isFormValid();
    }

    handleComments(event){
        this.enquiryForm.comments = event.detail.value;
        this.isFormValid();
    }

    handleAccount(event){
        this.enquiryForm.account = event.detail.value;
        this.isFormValid();
    }

    isFormValid(){
        this.formInvalid = !(this.enquiryForm['enquiryType'] && this.enquiryForm['firstName'] && this.enquiryForm['lastName']
                             && this.enquiryForm['email'] && this.enquiryForm['country'] && this.enquiryForm['holidayType'] 
                             && this.enquiryForm['numberOfAdults'] &&this.enquiryForm['account']);

    }

    submit(){
        console.log(this.enquiryForm);
        saveEnquiry({ data: this.enquiryForm })
            .then((result) => {
                this.navigateToRecordViewPage(result.Id);
            })
            .catch((err) => {
                console.error(err);
            });
    }

    navigateToRecordViewPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Enquiry__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

}
