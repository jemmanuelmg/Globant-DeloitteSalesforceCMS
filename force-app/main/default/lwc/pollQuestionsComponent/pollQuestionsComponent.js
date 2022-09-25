import { LightningElement, track, api } from 'lwc';
import getUser from "@salesforce/apex/PollsController.getUser";
import getPoll from "@salesforce/apex/PollsController.getPoll";

export default class PollQuestionsComponent extends LightningElement {
  
    @track pollId;
    @api recordId;
    @track poll;
    @track showPoll;
    @track isLoading;

    user;

    firstLoad = true;

    setupForLocalTesting()
    {
        // properties for testing purpose
        // override this when is needed

        this.pollId = 'a3h0n000000BT13AAG';
        this.showPoll = false;
    }

    async fetchUser()
    {
        try
        {
            this.user = await getUser();
        }
        catch(error)
        {
            console.error("Error fetchUser:");
            console.error(error);
        }
    }

    async fetchPoll()
    {
        try
        {
            this.getUrlParameters();

            let pollIdParam = this.pollId;
            console.log('Poll id antes de enviarlo a getPoll() es');
            console.log(pollIdParam);

            getPoll({pollId : pollIdParam})
            .then((pollInfo) => {

                this.poll = pollInfo;
                this.showPoll = true;

            })
            .catch(error => {
                
                console.log('Error in getPoll()');
                this.printError(error);

            });

        }
        catch(error)
        {
            console.error("Error fetchPoll:");
            console.error(error);
        }
    }

    printError(error) 
    {
        console.log("Error name", error.name);
        console.log("Error message", error.message);
        console.log("Error stack", error.stack);
    }

    getUrlParameters()
    {
        let url = new URL(window.location.href);
        const urlParams = url.searchParams;
        let isValid = false;

        this.pollId = urlParams.get('c__recordId');

        if (this.pollId) {
            isValid = true;
        }

        console.log('>>>> El poll id');
        console.log(this.pollId);

        return isValid;
    }

    async connectedCallback() 
    {   
        this.isLoading = true;
        await this.fetchUser();
        await this.fetchPoll();
        this.isLoading = false;

    }

    reloadComponent() {
        this.connectedCallback();
    }
}