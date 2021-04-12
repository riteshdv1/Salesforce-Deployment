import { LightningElement, wire } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class PackageContent extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    packageContent;

    connectedCallback() {
        registerListener('packagecontent', this.handlePackageContent, this)
    }

    handlePackageContent(packageContentString) {
        this.packageContent = undefined;
        if (packageContentString) {
            let result = JSON.parse(packageContentString);
            this.packageContent = [];
            for (let element of result) {
                let content = {};
                content.name = element.name;
                content.members = element.members;
                this.packageContent.push(content);
            }
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}