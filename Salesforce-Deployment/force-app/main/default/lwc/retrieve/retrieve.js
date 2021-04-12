import { LightningElement, track, wire, api } from "lwc";
import getAllRetrieveJobs from '@salesforce/apex/RetrieveController.getAllRetrieveJobs';
import refresh from '@salesforce/apex/RetrieveController.refresh';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Retrieve extends LightningElement {
  @track retrieveList;
  @track paginationList;
  showModal = false;
  @api pageSize = 5;
  currentPage = 1;
  totalPages = 1;

  @wire(CurrentPageReference) pageRef;
  connectedCallback() {
    registerListener('refresh', this.handleRefresh, this);
    this.retrieveAll();
  }

  handleRefresh() {
    refresh()
      .then((result) => {
        if (result == 'Success') {
          this.retrieveAll();
        } else {
          this.displayMessage('error', json.stringify(error), 'error');
        }
      })
      .catch((error) => {
        this.displayMessage('error', error.body.message, 'error');
      })
  }
  retrieveAll() {
    this.retrieveList = [];
    getAllRetrieveJobs()
      .then((result) => {
        let resultList = JSON.parse(JSON.stringify(result));
        this.totalPages = Math.ceil(resultList.length / this.pageSize);
        for (let retrieveRecord of resultList) {
          if (retrieveRecord.Status__c == "Success") {
            retrieveRecord.class = "background-color:rgb(101, 243, 101);";
          } else if (retrieveRecord.Status__c == "Failed") {
            retrieveRecord.class = "background-color:rgb(245, 94, 94)";
          } else {
            retrieveRecord.class = "background-color:rgb(235, 235, 60);";
          }
          this.retrieveList.push(retrieveRecord);
        }
        this.getPaginationList();
      })
      .catch((error) => {
        this.retrieveList = undefined
        this.displayMessage('error', error.body.message, 'error');
      })
  }

  getPaginationList() {
    let startIndex = (this.currentPage - 1) * this.pageSize;
    let endIndex = this.currentPage * this.pageSize;
    let x = 0;
    this.paginationList = [];
    for (let item of this.retrieveList) {
      if (x >= startIndex && x < endIndex) {
        this.paginationList.push(item);
      }
      x++;
    }
  }

  handleNext() {
    if (this.currentPage < this.totalPages) {
      this.currentPage = this.currentPage + 1;
    }
    this.getPaginationList();
  }

  handlePrevious() {
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1;
    }
    this.getPaginationList();
  }

  handleRecordClick(event) {
    const dataId = event.currentTarget.dataset.id;
    const retrieveRecord = this.retrieveList.find(element => element.Id == dataId)
    let message = {
      detail: retrieveRecord
    }
    fireEvent(this.pageRef, "retrievedetails", message);
    fireEvent(this.pageRef, "packagecontent", retrieveRecord.PackageContentJson__c);
  }

  disconnectedCallback() {
    unregisterAllListeners(this);
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