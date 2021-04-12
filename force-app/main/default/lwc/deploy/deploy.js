import { LightningElement, track, wire, api } from "lwc";
import getAllDeployJobs from '@salesforce/apex/DeployController.getAllDeployJobs';
import cancelDeploy from '@salesforce/apex/DeployController.cancelDeploy';
import refresh from '@salesforce/apex/DeployController.refresh';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Deploy extends LightningElement {
    @track deployList;
    @track paginationList;
    showModal = false;
    @api pageSize = 5;
    currentPage = 1;
    totalPages = 1;

    @wire(CurrentPageReference) pageRef;
    connectedCallback() {
        registerListener('refresh', this.handleRefresh, this);
        this.deployAll();
    }

    handleRefresh() {
        refresh()
            .then((result) => {
                if (result == 'Success') {
                    this.deployAll();
                } else {
                    this.displayMessage('error', json.stringify(error), 'error');
                }
            })
            .catch((error) => {
                this.displayMessage('error', error.body.message, 'error');
            })
    }
    deployAll() {
        this.deployList = [];
        getAllDeployJobs()
            .then((result) => {
                let resultList = JSON.parse(JSON.stringify(result));
                this.totalPages = Math.ceil(resultList.length / this.pageSize);
                for (let deployRecord of resultList) {
                    if (deployRecord.Status__c == "Success") {
                        deployRecord.class = "background-color:rgb(101, 243, 101);";
                        deployRecord.inProgress = false;
                    } else if (deployRecord.Status__c == "Failure") {
                        deployRecord.class = "background-color:rgb(245, 94, 94)";
                        deployRecord.inProgress = false;
                    } else {
                        deployRecord.class = "background-color:rgb(235, 235, 60);";
                        deployRecord.inProgress = true;
                    }
                    this.deployList.push(deployRecord);
                }
                this.getPaginationList();
            })
            .catch((error) => {
                this.deployList = undefined
                this.displayMessage('error', error.body.message, 'error');
            })
    }



    handleRecordClick(event) {
        const dataId = event.currentTarget.dataset.id;
        const deployRecord = this.deployList.find(element => element.Id == dataId)
        let message = {
            detail: deployRecord
        };
        fireEvent(this.pageRef, "deploydetails", message);
        fireEvent(this.pageRef, "componenterrors", deployRecord.ComponentFailures__c);
        fireEvent(this.pageRef, "packagecontent", deployRecord.Retrieve__r.PackageContentJson__c);
    }

    handleCancelDeploy(event) {
        let input = {
            deployJobId: event.currentTarget.dataset.id
        }
        cancelDeploy(input)
            .then((result) => {
                if (result == 'Success') {
                    this.displayMessage('Success', 'Successfully cancelled deployment', 'Success');
                } else {
                    this.displayMessage('error', result, 'error');
                }

            }).catch((error) => {
                this.displayMessage('error', error.message.body, 'error');
            })

    }

    getPaginationList() {
        let startIndex = (this.currentPage - 1) * this.pageSize;
        let endIndex = this.currentPage * this.pageSize;
        let x = 0;
        this.paginationList = [];
        for (let item of this.deployList) {
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