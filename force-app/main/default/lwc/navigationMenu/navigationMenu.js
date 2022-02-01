import { LightningElement, track } from 'lwc';
import isAdmin from '@salesforce/apex/CommunityController.isAdmin';
import Id from '@salesforce/user/Id';

export default class NavigationMenu extends LightningElement {
    isAdmin;
    userId = Id;
    homeValue;    
    carsValue;
    appointmentsValue;
    simulatorValue;

    connectedCallback(){
        isAdmin({userId : this.userId})
        .then(result => {
            this.isAdmin = result;
            console.log(idUser);
        })
        .catch(error => {
            this.error = error;
        })
    }

    atHome(){
        this.homeValue = true;
        this.carsValue = false;
        this.appointmentsValue = false;
        this.simulatorValue = false;
    }

    atCars(){
        this.homeValue = false;
        this.carsValue = true;
        this.appointmentsValue = false;
        this.simulatorValue = false;
    }

    atAppointments(){
        this.homeValue = false;
        this.carsValue = false;
        this.appointmentsValue = true;
        this.simulatorValue = false;
    }

    atSimulator(){
        this.homeValue = false;
        this.carsValue = false;
        this.appointmentsValue = false;
        this.simulatorValue = true;
    }
}