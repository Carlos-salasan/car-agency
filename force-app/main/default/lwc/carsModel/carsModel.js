import { LightningElement, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import ISACTIVE_FIELD from '@salesforce/schema/Product2.IsActive';
import BRAND_FIELD from '@salesforce/schema/Product2.Brand__c';
import COLOR_FIELD from '@salesforce/schema/Product2.Color__c';
import MODEL_FIELD from '@salesforce/schema/Product2.Model__c';
import PRICE_FIELD from '@salesforce/schema/Product2.Price__c';
import uploadFile from '@salesforce/apex/CommunityController.uploadFile';

export default class CarsModel extends LightningElement {
    productId;
    isActive = false;
    brandVal;
    colorVal;
    modelVal;
    price;
    fileName;
    fileData;
    file;
    isModalOpen = false;

    
    openModal() {
        this.isModalOpen = true;
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
    
    handleNameChange(event) {
        this.name = event.target.value;
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
    handlePriceChange(event){
        this.price = event.target.value;
    }
    handleIsActiveChange(event){
        this.isActive = event.target.checked;
    }
    handleFilesChange(event){
        this.file = event.target.files[0];
        var reader = new FileReader();
        reader.onload=()=>{
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'filename':this.file.name,
                'base64':base64,
                'recordId':this.productId
            }
            console.log(this.fileData);
        }
        this.fileName = this.file.name;
        reader.readAsDataURL(this.file)
    }

    createProduct() {
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.name;
        fields[MODEL_FIELD.fieldApiName] = this.model;
        fields[BRAND_FIELD.fieldApiName] = this.brand;
        fields[COLOR_FIELD.fieldApiName] = this.color;
        fields[PRICE_FIELD.fieldApiName] = this.price;
        fields[ISACTIVE_FIELD.fieldApiName] = this.isActive;
        const recordInput = { apiName: PRODUCT_OBJECT.objectApiName, fields };
        this.isModalOpen = false;
        createRecord(recordInput)
            .then(product => {
                this.productId = product.id;
                console.log('Filename' + this.fileData.filename);
                console.log('base64' + this.fileData.base64);
                console.log('id' + this.productId);
                uploadFile({filename:this.fileData.filename, base64:this.fileData.base64, recordId:this.productId})
                .then(result =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Product created: ' + this.productId,
                            variant: 'success',
                        }),
                    );
                })
                .catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating file',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    this.createDiabled = false;
                })
                this.createDiabled = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.createDiabled = false;
            });
    }

    closeModal(){
        this.isModalOpen = false;
    }
}