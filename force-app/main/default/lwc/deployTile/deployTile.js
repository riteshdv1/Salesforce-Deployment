import { LightningElement, wire } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';


export default class DeployTile extends LightningElement {
    label = {
        "status": "Status",
        "createdDate": "Created Date",
        "createdby": "Created By",
        "environment": "Environment",
        "members": "Members",
        "retrieveJob": "Retrieve Job"
    };
    OBJECT = 'Deploy__c';
    VIEW = 'view';
    TYPE = 'standard__recordPage';
    deployRecord;
    deployRecordUrl;
    hasRendered = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener("deploydetails", this.handleRecordDetail, this);
    }

    renderedCallback() {
        if (!this.hasRendered && this.deployRecord) {
            this.generateDeployRecordUrl();
            this.hasRendered = true;
        }
    }

    generateDeployRecordUrl() {
        const navigator = this.template.querySelector('c-navigate-to-record');
        navigator.generateUrl(this.TYPE, this.deployRecord.Id, this.OBJECT, this.VIEW)
    }

    handleRecordDetail(eventRecord) {
        this.deployRecord = eventRecord.detail;
    }

    handleRetrieveUrl(event) {
        this.deployRecordUrl = event.detail;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}