import { LightningElement } from 'lwc';
import getActiveProducts from '@salesforce/apex/CommunityController.getActiveProducts';

export default class ImageCarousel extends LightningElement {
    products = [];

    connectedCallback(){
        getActiveProducts()
        .then(result => {
            this.products = result;
        })
        .catch(error => {
            this.error = error;
        })
    }
}