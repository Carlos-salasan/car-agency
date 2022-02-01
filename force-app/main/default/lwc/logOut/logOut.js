import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class LogOut extends NavigationMixin(LightningElement) {
    logOut(){
        this[NavigationMixin.Navigate]({
             type: 'comm__loginPage',
             attributes: {
                actionName: 'logout'
             }
         });
    }
}