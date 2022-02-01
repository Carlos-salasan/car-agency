import { LightningElement, wire, api } from 'lwc';
import getAvailableCars from '@salesforce/apex/CommunityController.getAvailableCars';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import BRAND_FIELD from '@salesforce/schema/Product2.Brand__c';
import COLOR_FIELD from '@salesforce/schema/Product2.Color__c';
import MODEL_FIELD from '@salesforce/schema/Product2.Model__c';

const COLS = [
    { label: 'Vehicle', fieldName: 'Name' },
    { label: 'Model', fieldName: 'Model__c' },
    { label: 'Brand', fieldName: 'Brand__c' },
    { label: 'Color', fieldName: 'Color__c', },
    { label: 'Price', fieldName: 'Price__c', type: 'currency'},
    {
        label: 'Picture',
        type: 'customPictureType',
        typeAttributes: {
            pictureUrl: { fieldName: 'DisplayUrl' }
        },
        cellAttributes: { alignment: 'center' }
    },
];

export default class ClientsTable extends LightningElement {
    @api recordId;
    brandVal;
    colorVal;
    modelVal;
    model = null;
    color = null;
    brand = null;
    columns = COLS;
    draftValues = [];
    products;

    connectedCallback(){
        this.searchProduct();
    }

    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT }) productMetadata;
    @wire(getPicklistValues,{
        recordTypeId: '$productMetadata.data.defaultRecordTypeId', 
        fieldApiName: MODEL_FIELD
    })
    modelValue({ error, data }) {
        if (data) {
            this.modelVal = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    } 
    @wire(getPicklistValues,{
        recordTypeId: '$productMetadata.data.defaultRecordTypeId', 
        fieldApiName: BRAND_FIELD
    })
    brandValue({ error, data }) {
        if (data) {
            this.brandVal = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }  
    @wire(getPicklistValues,{
        recordTypeId: '$productMetadata.data.defaultRecordTypeId', 
        fieldApiName: COLOR_FIELD
    })
    colorValue({ error, data }) {
        if (data) {
            this.colorVal = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    handleModelChange(event){
        this.model = event.target.value;
    }
    handleBrandChange(event){
        this.brand = event.target.value;
    }
    handleColorChange(event){
        this.color = event.target.value;
    }

    searchProduct(){
        console.log(this.model);
        console.log(this.brand);
        console.log(this.color);
        getAvailableCars({model: this.model, brand: this.brand, color: this.color})
        .then((result) => {
            this.products = result;
            console.log(result);
        })
        
    }

}