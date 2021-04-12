import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewDeployJob from '@salesforce/apex/DeployController.createNewDeployJob';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

/**
 * Show an item
 */
export default class DeployNew extends LightningElement {
  environmentName;
  environmentId;
  retrieveJobName;
  retrieveJobId;
  testLevel;
  showEnvironmentErrorMsg;
  showpackageContentErrorMsg;
  loading = false;

  @wire(CurrentPageReference) pageRef;
  handleCancel() {
    const cancelEvent = new CustomEvent("cancel");
    this.dispatchEvent(cancelEvent);
  }

  onEnvironmentSelection(event) {
    this.environmentName = event.detail.selectedValue;
    this.environmentId = event.detail.selectedRecordId;
  }

  onRetrieveSelection(event) {
    this.retrieveJobName = event.detail.selectedValue;
    this.retrieveJobId = event.detail.selectedRecordId;
  }

  handlePackageContent(event) {
    this.packageFileContent = event.detail.value;
  }

  handleTestLevel(event) {
    this.testLevel = event.detail.value;
  }
  handleSave() {
    if (!this.environmentId) {
      this.showEnvironmentErrorMsg = 'Select an environment';
      return;
    } else if (!this.retrieveJobId) {
      this.showRetrieveErrorMsg = 'Select a retrieve job';
      return;
    }
    this.loading = true;
    let deployOptions = {
      testLevel: this.testLevel,
      runTests: []
    }
    let inputs = {
      environmentId: this.environmentId,
      retrieveJobId: this.retrieveJobId,
      optionsString: JSON.stringify(deployOptions)
    }
    createNewDeployJob(inputs)
      .then((result) => {
        this.loading = false;
        if (result.length === 15 || result.length === 18) {
          this.displayMessage('success', 'created record : ' + result, 'success');
          //FireRefresh event
          fireEvent(this.pageRef, 'refresh', null);
          this.handleCancel();
        } else {
          this.displayMessage('error', result, 'error');
        }
      }).catch((error) => {
        this.loading = false;
        this.displayMessage('error', JSON.stringify(error.body.message), 'error');
      })
  }

  displayMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      }),
    );
  }
}