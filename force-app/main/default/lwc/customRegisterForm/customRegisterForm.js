import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import customCss from '@salesforce/resourceUrl/customRegisterFormGlobalStyles'
import registerNewUser from "@salesforce/apex/CustomRegistrationController.registerNewUser";
import { NavigationMixin } from 'lightning/navigation';

export default class CustomRegisterForm extends NavigationMixin(LightningElement) {
    @track firstName;
    @track lastName;
    @track email;
    @track isLoading;
    @track showErrorPanel;
    @track errorMessage;

    renderedCallback() 
    {
        Promise.all([loadStyle(this, customCss)])
        .then(() => {
            console.log("static resources loaded");
        })
        .catch(error => {
            console.error('Error in renderedCallback');
            this.printError(error);
        });
    }

    registerUser() {

        this.isLoading = true;
        this.showErrorPanel = false;
        const form = this.template.querySelector('.registerForm');

        if (!form.reportValidity()) {
            this.isLoading = false;
            return false;
        }

        this.showToast('Loading', 'Processing registration', 'info');

        let firstNameParam = this.template.querySelector('lightning-input[data-name="firstName"]').value;
        let lastNameParam = this.template.querySelector('lightning-input[data-name="lastName"]').value;
        let emailParam = this.template.querySelector('lightning-input[data-name="email"]').value;

        let paramObject = {
            firstName: firstNameParam,
            lastName: lastNameParam,
            email: emailParam
        }

        registerNewUser(paramObject)
        .then((data) => {
                        
            this.isLoading = false;
            console.log('>>> Returned value in registerUser method is');
            console.log(data);

            if (data.includes('DUPLICATE_USERNAME')) {

                this.showErrorPanel = true;
                this.errorMessage = 'This email address is already registered. Please click on "Forgot your password?" from the login page to recover your password or use a different email.';
                this.showToast('Error', 'Error during registration', 'error');

            } else if (data.includes('EXCEPTION')) {

                this.showErrorPanel = true;
                this.errorMessage = 'There was an unexpected error. Please try to register again in thirty (30) seconds. If the problem persists please contact us and we will assist you.';
                this.showToast('Error', 'Error during registration', 'error');

            } else {

                this.showToast('Registered successfully', 'Please check your email to confirm your account', 'success');
                setTimeout(() => {
                    this.navigateToRegisterSuccess();
                }, 1000);

            }
            
        })
        .catch(error => {
            console.log('Error on registerUser2()');
            this.printError(error);
            this.isLoading = false;
        });

    }

    navigateToRegisterSuccess() {

        let baseUrl = window.location.href;
        let successUrl;
        if (baseUrl.includes('cfolens.deloitte.com')) {
            successUrl = '/s/registerSuccess';
        } else {
            successUrl = '/registerSuccess';
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: successUrl
            },
        });
    }

    showToast(title, message, variant) {

        console.log('Entered in showToast');
        const evt = new ShowToastEvent({
            title: title, 
            message: message, 
            variant: variant
        });

        this.dispatchEvent(evt); 
        console.log('Exiting in showToast');      

    }
}