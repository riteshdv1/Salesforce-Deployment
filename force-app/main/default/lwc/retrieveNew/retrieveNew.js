import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewRetrieveJob from '@salesforce/apex/RetrieveController.createNewRetrieveJob';
import getMetadataTypes from '@salesforce/apex/RetrieveController.getMetadataTypes';
import getMetadataElementsByType from '@salesforce/apex/RetrieveController.getMetadataElementsByType';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

/**
 * Show an item
 */
export default class Child extends LightningElement {
  environmentName;
  environmentId;
  showEnvironmentErrorMsg;
  showpackageContentErrorMsg;
  selectedElement; // Default
  firstPage = true;
  treeData;
  validationError;
  @track members;
  searchKey;
  loading = false;

  @wire(CurrentPageReference) pageRef;
  handleCancel() {
    const cancelEvent = new CustomEvent("cancel");
    this.dispatchEvent(cancelEvent);
  }

  handleSuccess(event) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: event.detail.apiName + ' created.',
        variant: 'success',
      }),
    );
  }

  onEnvironmentSelection(event) {
    this.environmentName = event.detail.selectedValue;
    this.environmentId = event.detail.selectedRecordId;
  }

  handlePackageContent(event) {
    this.packageFileContent = event.detail.value;
  }

  handleNext() {
    this.validationError = undefined;
    if (!this.environmentId) {
      this.validationError = 'Select an environment';
      return;
    }
    this.loading = true;
    let input = { environmentId: this.environmentId };
    getMetadataTypes(input)
      .then((response) => {
        this.loading = false;
        if (response.isSuccess && response.result) {
          let result = JSON.parse(JSON.stringify(response.result));
          this.initializeTreeData(result);
          this.firstPage = false;
        } else {
          let errorMsg = JSON.parse(JSON.stringify(response.result));
          this.displayMessage('error', errorMsg, 'error');
        }
      })
      .catch((error) => {
        this.loading = false;
        this.displayMessage('error', error.body.message, 'error');
      })
  }

  initializeTreeData(result) {
    this.treeData = [];
    for (let item of result) {
      let element = {
        name: item.xmlName,
        folderName: item.directoryName,
        members: []
      }
      this.treeData.push(element);
    }
  }

  handlePrevious() {
    this.firstPage = true;
    this.environmentName = undefined;
    this.environmentId = undefined;
    this.selectedElement = undefined;
    this.members = undefined;
  }
  handleSave() {
    this.loading = true;
    let inputs = {
      environmentId: this.environmentId,
      packageInputs: JSON.stringify(this.treeData)
    }
    createNewRetrieveJob(inputs)
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
        this.displayMessage('error', error.body.message, 'error');
      })
  }

  get elements() {
    let tempArr = [];
    for (let item of this.treeData) {
      if (item.name) {
        let arrElement = {
          label: item.name,
          value: item.name
        }
        tempArr.push(arrElement);
      }
    }
    return tempArr;
  }

  handleSelection(event) {
    this.loading = true;
    this.selectedElement = event.detail.value
    let currentSelection = this.treeData.find(item => item.name == this.selectedElement);
    this.members = [];
    this.members = currentSelection.members;
    if (this.members.length != 0) {
      this.loading = false;
      return;
    }
    let input = {
      environmentId: this.environmentId,
      type_x: currentSelection.name,
      folderName: currentSelection.folderName
    }
    getMetadataElementsByType(input)
      .then((response) => {
        this.loading = false;
        if (response.isSuccess && response.result) {
          let result = JSON.parse(JSON.stringify(response.result));
          this.addMembersToTreeData(this.selectedElement, result);
        } else {
          this.displayMessage('error', JSON.stringify(response.result), 'error');
        }
      }).catch((error) => {
        this.loading = false;
        this.displayMessage('error', JSON.stringify(error), 'error');
      })
  }


  addMembersToTreeData(name, result) {
    let memberArray = [];
    for (let item of result) {
      let tempObj = {
        name: item.fullName,
        show: true
      }
      memberArray.push(tempObj);
    }

    for (let item of this.treeData) {
      if (item.name == name) {
        item.members = memberArray;
        break;
      }
    }
    this.members = memberArray
  }

  handleMemberSearch(event) {
    this.searchKey = event.currentTarget.value;
    for (let member of this.members) {
      member.show = true;
      if (this.searchKey && !member.name.toLowerCase().includes(this.searchKey.toLowerCase())) {
        member.show = false;
      }
    }
  }

  handleMemberClick(event) {
    let currentMember = event.currentTarget.dataset.name;
    let tempArr = [];
    for (let element of this.treeData) {
      if (element.name == this.selectedElement) {
        let memberCount = 0;
        for (let item of element.members) {
          if (item.name == currentMember) {
            item.isSelected = !item.isSelected;
            item.class = item.isSelected ? "background-color:green;color:white;" : " ";
          }
          if (item.isSelected) {
            memberCount++;
          }
        }
        element.isSelected = memberCount > 0 ? true : false;
      }
      tempArr.push(element)
    }
    this.treeData = tempArr;
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