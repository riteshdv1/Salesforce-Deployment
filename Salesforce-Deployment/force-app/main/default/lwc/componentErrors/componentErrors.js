import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
export default class ComponentErrors extends LightningElement {
    label = {
        type: "Type",
        fileName: "File Name",
        error: "Error Message",
        line: "Line",
        column: "Column"
    }
    componentErrorList;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('componenterrors', this.handleComponentErrors, this)
    }

    handleComponentErrors(componentErrorString) {
        this.componentErrorList = undefined;
        if (componentErrorString) {
            this.componentErrorList = JSON.parse(componentErrorString);
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}