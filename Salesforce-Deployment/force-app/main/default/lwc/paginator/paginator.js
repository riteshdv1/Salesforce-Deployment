import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    @api currentPage;
    @api totalPages;
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}