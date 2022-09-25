import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAvailableEvents from '@salesforce/apex/ShowEventsListController.getAvailableEvents';
export default class showEventsList extends NavigationMixin(LightningElement) {

   @track upcomingEvents =[];
   @track pastEvents = [];
   @track upcomingEventsExists;
   @track pastEventsExists;
   @api baseUrl;
 

    connectedCallback() { 
    
        getAvailableEvents({mode : 'upcoming'})
        .then((upcomingEvents) => {

            upcomingEvents = JSON.parse(JSON.stringify(upcomingEvents));
            console.log('>>> The upcomingEvents received');
            console.log(upcomingEvents);
            this.upcomingEvents = this.normalizeFieldsOnData(upcomingEvents);
            
            if (this.upcomingEvents.length > 0) {
                this.upcomingEventsExists = true;
            } else {
                this.upcomingEventsExists = false;
            }

        })
        .catch(error => {
            console.log('Error in getAvailableEvents() (upcoming events) ');
            this.printError(error);
        });

        getAvailableEvents({mode : 'past'})
        .then((pastEvents) => {

            pastEvents = JSON.parse(JSON.stringify(pastEvents));
            console.log('>>> The pastEvents received');
            console.log(pastEvents);
            this.pastEvents = this.normalizeFieldsOnData(pastEvents);
            
            if (this.pastEvents.length > 0) {
                this.pastEventsExists = true;
            } else {
                this.pastEventsExists = false;
            }

        })
        .catch(error => {
            console.log('Error in getAvailableEvents() (past events)');
            this.printError(error);
        });

    }

    normalizeFieldsOnData(data) {
        
        let resultList = [];
        for (let i = 0; i < data.length; i ++) {

            let element = data[i];
            element.detailLink = "/s/event-detail?c__eventId=" + element.Id;

            if (element.Additional_Event_Informations__r) {
                element.bannerImage = this.getBannerImage(element.Additional_Event_Informations__r);
            }

            if (element.Event_Start_Date__c) {
                let dateObject = new Date(element.Event_Start_Date__c);
                element.Event_Start_Date__c = dateObject.toLocaleDateString();
            }

            if (element.Event_End_Date__c) {
                let dateObject = new Date(element.Event_End_Date__c);
                element.Event_End_Date__c = dateObject.toLocaleDateString();
            }
            
            resultList.push(element);

        }

        return resultList;

    }

    getBannerImage(additionalInfoList) {

        let bannerImgRec = {};
        additionalInfoList.forEach(element => {

            if (element.Type__c == 'Event Banner') {
                bannerImgRec = element;
            }

        });

        if (bannerImgRec.Content__c) {
            return bannerImgRec.Content__c;
        } else {
            return '<p>No image available</p>';
        }

    }

    printError(error) {

        console.log('Error information');
        console.log(error.message);
        console.log(error.stack);
        console.log(JSON.parse(JSON.stringify(error)));

    }

    navigateToDetails(event) {
        
        let baseUrl = window.location.href;    
        let domainName = baseUrl.substr(0, 28);
        let eventId = event.currentTarget.dataset.eventid;
        let redirectUrl = '';

        if (domainName != 'https://cfolens.deloitte.com') {
            redirectUrl = '/CFOProgram/s/event-detail?c__eventId=' + eventId;
        } else {
            redirectUrl = '/s/event-detail?c__eventId=' + eventId;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: redirectUrl
            },
        });

    }
 
}