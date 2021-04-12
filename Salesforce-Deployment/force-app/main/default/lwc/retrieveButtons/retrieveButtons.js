import { LightningElement, wire } from 'lwc';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class RetrieveButtons extends LightningElement {
    showModal = false;
    @wire(CurrentPageReference) pageRef
    handleNew() {
        this.showModal = true;
    }
    handleCancel() {
        this.showModal = false;
    }
    handleRefresh() {
        fireEvent(this.pageRef, 'refresh', null);
    }
}