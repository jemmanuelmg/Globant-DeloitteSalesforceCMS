import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPolls from '@salesforce/apex/PollsListController.getPolls';

export default class ListPolls extends NavigationMixin(LightningElement) {

    @track polls = [];
    @track pollsExists;
    @track isLoading;
    @api baseUrl;


    connectedCallback() 
    { 
        this.isLoading = true;

        getPolls()
        .then((polls) => {

            polls = JSON.parse(JSON.stringify(polls));

            polls.forEach(element => {
                let Id = element.Id
                element.pollUrl = "/s/polls/poll?c__recordId=" + Id;
                element.expiryDate = (new Date(element.Expire_Date__c)).toISOString().substring(0, 10);;
            });

            this.polls = polls;

            if(this.polls.length > 0){
                this.pollsExists = true;
            }

            this.isLoading = false;

        })
        .catch(error => {
            console.log('Error in getPolls() ');
            this.printError(error);
            this.isLoading = false;
        });
    }

    printError(error) {
        console.log('Error information');
        console.log(error.message);
        console.log(error.stack);
        console.log(JSON.parse(JSON.stringify(error)));
    }

    navigateToDetails(event) {

        let pollId = event.currentTarget.dataset.pollid;

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: "/s/polls/poll?c__recordId=" + pollId
            },
        });

    }

}