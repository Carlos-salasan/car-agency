import { LightningElement, wire, api } from 'lwc';
import getAllCars from '@salesforce/apex/CommunityController.getAllCars';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/Product2.Id';
import ACTIVE_FIELD from '@salesforce/schema/Product2.IsActive';


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
    { label: 'Available?', fieldName: 'IsActive', type: 'boolean',cellAttributes: { alignment: 'center' } , editable:true}
];
export default class DatatableCustomDataType extends LightningElement {
    @api recordId;
    columns = COLS;
    draftValues = [];

    @wire(getAllCars)
    products;

    handleSave(event) {
        const fields = {}; 
        fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        fields[ACTIVE_FIELD.fieldApiName] = event.detail.draftValues[0].IsActive;

        const recordInput = {fields};

        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Product updated',
                    variant: 'success'
                })
            );
            // Display fresh data in the datatable
            return refreshApex(this.products).then(() => {

                // Clear all draft values in the datatable
                this.draftValues = [];

            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}
