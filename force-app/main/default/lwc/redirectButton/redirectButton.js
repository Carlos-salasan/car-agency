import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RedirectButton extends NavigationMixin(LightningElement) {
    navigateHome() {
        this[NavigationMixin.Navigate]({
             type: 'comm__namedPage',
             attributes: {
                  name: 'Home'
             }
         });
    }
}