import { LightningElement, wire, api, track } from 'lwc';
import getWebToLeadLeads from '@salesforce/apex/CommunityController.getWebToLeadLeads';
import leadToUpt from '@salesforce/apex/CommunityController.leadToUpt';
import assignUser from '@salesforce/apex/CommunityController.assignUser';
import getAdminUsers from '@salesforce/apex/CommunityController.getAdminUsers';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Assign', name: 'assign' }
];

const COLS = [
    { label: 'Name', fieldName: 'FirstName'},
    { label: 'Last Name', fieldName: 'LastName'},
    { label: 'Email', fieldName: 'Email', type: 'email'},
    { label: 'Company', fieldName: 'Company'},
    { label: 'City', fieldName: 'City'},
    { label: 'State', fieldName: 'State'},
    { type: 'action', 
        typeAttributes: 
        { 
            rowActions: actions, 
            menuAlignment: 'right'
        }
    }
];

export default class LeadsTable extends LightningElement {
    @api recordId;
    @track record;
    columns = COLS;
    allWebToLeadLeads = [];
    allAdminUsers = [];
    isModalOpen = false;
    isAssignModalOpen = false;
    userVal;
    fname;
    lname;
    lemail;
    lcompany;
    lcity;
    lstate;
    userSelected;
    message = '';

    @wire(getWebToLeadLeads)
    leads({error, data}){
        if(data){
            this.allWebToLeadLeads = data;
        } else if(error){
            this.error = error;
        }
    }

    handleFNameChange(event) {
        this.fname = event.target.value;
    }
    handleLNameChange(event){
        this.lname = event.target.value;
    }
    handleEmailChange(event){
        this.lemail = event.target.value;
    }
    handleCompanyChange(event) {
        this.lcompany = event.target.value;
    }
    handleCityChange(event){
        this.lcity = event.target.value;
        console.log(event.target.value);
    }
    handleStateChange(event){
        this.lstate = event.target.value;
    }
    handleUserChange(event){
        this.userSelected = event.detail.value;
    }
    
    handleRowAction(event){
        let action = event.detail.action.name;
        this.record = event.detail.row;

        this.fname = this.record.FirstName;
        this.lname = this.record.LastName;
        this.lemail = this.record.Email;
        this.lcompany = this.record.Company;
        this.lcity = this.record.City
        this.lstate = this.record.State;
        this.recordId = this.record.Id;

        console.log(JSON.stringify(this.record));
        if(action == "edit"){
            this.isModalOpen = true;
        }else{
            this.users();
            this.isAssignModalOpen = true;
        }
    }

    closeModal(){
        this.isModalOpen = false;
        this.isAssignModalOpen = false;
    }

    users(){
        getAdminUsers()
        .then((result) => {
            this.allAdminUsers = result;
            this.userVal = [];
            for(var i = 0; i < result.length; i++){
                let labelLine = result[i].Assignee.Name;
                let valueLine = result[i].Assignee.Id;
                let option = {label : labelLine, value : valueLine};
                this.userVal.push(option);
            }
        });
    }

    assignLead(){
        this.isAssignModalOpen = false;
        assignUser({recordId : this.recordId, userId : this.userSelected})
        .then(() => {
            let found = this.userVal.find(element => element.value == this.userSelected);
            this.message = 'This lead have been assigned to ' + found.label;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.message,
                    variant: 'success'
                })
            );
        })
    }

    updateLead() {
        this.isModalOpen = false;
        leadToUpt({leadId : this.recordId, FName : this.fname, LName : this.lname, Email : this.lemail, Company : this.lcompany,
             City: this.lcity, State: this.lstate})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Lead updated',
                    variant: 'success'
                })
            );
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading record',
                    message: error.body,
                    variant: 'error'
                })
            );
        });
    }
}