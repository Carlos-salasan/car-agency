import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class LogIn extends NavigationMixin(LightningElement) {
    logIn() {
        this[NavigationMixin.Navigate]({
             type: 'comm__loginPage',
             attributes: {
                actionName: 'login'
             }
         });
    }
}