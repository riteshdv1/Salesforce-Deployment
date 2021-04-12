import { LightningElement, wire } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';


export default class RetrieveTile extends LightningElement {
    label = {
        "status": "Status",
        "createdDate": "Created Date",
        "createdby": "Created By",
        "environment": "Environment",
        "members": "Members"
    };
    OBJECT = 'Retrieve__c';
    VIEW = 'view';
    TYPE = 'standard__recordPage';
    retrieveRecord;
    retrieveRecordUrl;
    hasRendered = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener("retrievedetails", this.handleRecordDetail, this);
    }

    renderedCallback() {
        if (!this.hasRendered && this.retrieveRecord) {
            this.generateRetrieveRecordUrl();
            this.hasRendered = true;
        }
    }

    generateRetrieveRecordUrl() {
        const navigator = this.template.querySelector('c-navigate-to-record');
        navigator.generateUrl(this.TYPE, this.retrieveRecord.Id, this.OBJECT, this.VIEW)
    }

    handleRecordDetail(eventRecord) {
        this.retrieveRecord = eventRecord.detail;
    }

    handleRetrieveUrl(event) {
        this.retrieveRecordUrl = event.detail;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}