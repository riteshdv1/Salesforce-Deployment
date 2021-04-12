import { LightningElement, wire } from 'lwc';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class DeployButtons extends LightningElement {
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