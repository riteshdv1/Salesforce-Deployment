import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigateToRecord extends NavigationMixin(LightningElement) {
    @api navigateToRecord(type, recordId, objectApiName, actionName) {
        this[NavigationMixin.Navigate]({
            type: type,
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: actionName
            }
        });
    }

    @api generateUrl(type, recordId, objectApiName, actionName) {
        // Generate a URL to a User record page
        this[NavigationMixin.GenerateUrl]({
            type: type,
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: actionName
            },
        }).then(url => {
            this.dispatchEvent(new CustomEvent('generateurl', { detail: url }));
        });
    }
}