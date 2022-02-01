import { LightningElement, wire } from 'lwc';
import simulator from '@salesforce/apex/CommunityController.simulator';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import TERM_FIELD from '@salesforce/schema/Product2.Term__c';
import MODEL_FIELD from '@salesforce/schema/Product2.Model__c';
import {exportCSVFile} from 'c/utils';


const COLS = [
    { label: 'Term', fieldName: 'term'},
    { label: 'Monthly Payment', fieldName: 'monthlyPayment'},
    { label: 'Total Paid Amount', fieldName: 'totalPaidAmount'},
    { label: 'Unpaid Balanced', fieldName: 'unpaidBalanced'}
];

export default class Simulator extends LightningElement {
    columns = COLS;
    termVal;
    modelVal;
    model;
    downPayment;
    term;
    totalAmount;
    allData;

    headers ={
        term:"Term",
        monthlyPayment:"Monthly Payment",
        totalPaidAmount:"Total Paid Amount",
        unpaidBalanced:"Unpaid Balanced"
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
        fieldApiName: TERM_FIELD
    })
    termValue({ error, data }) {
        if (data) {
            this.termVal = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    
    handleModelChange(event){
        this.model = event.target.value;
        console.log(event.target.value);
    }
    handleAmountChange(event){
        this.totalAmount = event.target.value;
        console.log(event.target.value);
    }
    handleDownPaymentChange(event){
        this.downPayment = event.target.value;
        console.log(event.target.value);
    }
    handleTermChange(event){
        this.term = event.target.value;
        console.log(event.target.value);
    }

    calculatePayment(){
        simulator({price : this.totalAmount, downPayment : this.downPayment, termOfSimulator : this.term})
        .then((result) => {
            this.allData = result;
            console.log(result);  
        })
    }

    downloadCSV(){
        console.log(this.allData);
        exportCSVFile(this.headers, this.allData, "Simulator");
    }
}