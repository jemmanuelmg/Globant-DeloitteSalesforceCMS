import { LightningElement, track, wire, api } from 'lwc';
import getInfoOfEvent from '@salesforce/apex/EventDetailViewerController.getInfoOfEvent';
import getBreakoutSessions from '@salesforce/apex/EventDetailViewerController.getBreakoutSessions';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class EventDetailViewer extends LightningElement {
    
    @track eventId;
    @track thereAreParameters;
    @track thereAreSessions;
    @track thereIsBanner;
    @track allSessionsGrouped = new Array();
    @track eventRecord;
    @track eventStartDate;
    @track eventEndDate;
    @track eventDescription;
    @track eventVenue;
    @track imageUrl;
    @track additionalNoticeText;
    @track hasAdditionalNotice;
    @track specialAgendas = [];
    @track attendees = [];
    @track usefulInformations = [];
    @track speakers = [];
    @track specialAgendasExists;
    @track attendeesExists;
    @track usefulInformationsExists;
    @track speakersExists;
    @track isLoading;
    @track bannerImage;
    @track noAddInformationRegistered = false;
    @api baseUrl;

    connectedCallback() { 

        this.isLoading = true;
        
        if (this.validateUrlParameters()) {

            this.thereAreParameters = true;
            let eventIdParam = this.eventId;

            getInfoOfEvent({eventId : eventIdParam})
            .then((data) => {

                data = JSON.parse(JSON.stringify(data));
                
                this.eventName = data.Source_Program_Event_Name__c;
                this.eventStartDate = data.Event_Start_Date__c;
                this.eventEndDate = data.Event_End_Date__c;
                this.eventDescription = data.Story_Feedback__c;
                this.eventVenue = data.Event_Venue__c;

                if (data.Additional_Notice_Text__c) {
                    this.additionalNoticeText = data.Additional_Notice_Text__c;
                    this.hasAdditionalNotice = true;
                }

                if (data.Additional_Event_Informations__r) {
                    if (data.Additional_Event_Informations__r.length > 0) {
                        this.extractAdditionalInformations(data.Additional_Event_Informations__r);
                    } 
                } else {
                    this.noAddInformationRegistered = true;
                }
                
                getBreakoutSessions({eventId : eventIdParam})
                .then((breakoutSessions) => {

                    if (data.Event_Sessions__r) {
                        if (data.Event_Sessions__r.length > 0) {

                            breakoutSessions = JSON.parse(JSON.stringify(breakoutSessions));

                            if (breakoutSessions) {
                                if (breakoutSessions.length > 0) {
                                    data.Event_Sessions__r.push(...breakoutSessions);
                                }
                            }

                            this.thereAreSessions = true;
                            this.createStartDateTimeOnSessions(data)
                            this.groupEventSpeakers(data);
                            this.groupSessionsByDay(data.Event_Sessions__r);

                        }
                    }

                    this.eventRecord = data;
                    this.isLoading = false;

                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('Error in connectedCallback() getBreakoutSessions');
                    this.printError(error);
                });

            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error in connectedCallback() getInfoOfEvent');
                this.printError(error);
            });


        } else {
            this.isLoading = false;
            this.thereAreParameters = false;
        }

    }

    extractAdditionalInformations(additionalInfos) {

        let specialAgendas = [];
        let attendees = [];
        let usefulInformations = [];
        let speakers = [];

        for (let i = 0; i < additionalInfos.length; i ++) {

            let info = additionalInfos[i];
            info.accordionSelector = 'accordion' + i;

            if (info.Type__c == 'Special Agendas') {

                specialAgendas.push(info);

            } else if (info.Type__c == 'Attendees') {

                attendees.push(info);

            } else if (info.Type__c == 'Useful Information') {

                usefulInformations.push(info);

            } else if (info.Type__c == 'Speakers') {

                speakers.push(info);

            } else if (info.Type__c == 'Event Banner') {

                this.bannerImage = info.Content__c;
                this.thereIsBanner = true;

            }

        }

        if (specialAgendas.length > 0) {
            this.specialAgendasExists = true;
            this.specialAgendas = specialAgendas;
        }

        if (attendees.length > 0) {
            this.attendeesExists = true;
            this.attendees = attendees;
        }

        if (usefulInformations.length > 0) {
            this.usefulInformationsExists= true;
            this.usefulInformations = usefulInformations;
        }

        if (speakers.length > 0) {
            this.speakersExists = true;
            this.speakers = speakers;
        }

        if (!this.specialAgendasExists && !this.usefulInformationsExists && !this.attendeesExists) {
            this.noAddInformationRegistered = true;
        }

    }

    groupEventSpeakers(data) {

        for (let i = 0; i < data.Event_Sessions__r.length; i++) {
            
            let speakerObjList = new Array();
            let session = data.Event_Sessions__r[i];

            if (session.Speaker_Faculty_Name_1__c) {
                let speakerObj = {};
                speakerObj.speakerName = session.Speaker_Faculty_Name_1__r.Name;
                speakerObj.speakerTitle = session.Speaker_Faculty_Name_1_Title__c;
                speakerObjList.push(speakerObj);
            }

            if (session.Speaker_Faculty_Name_2__c) {
                let speakerObj = {};
                speakerObj.speakerName = session.Speaker_Faculty_Name_2__r.Name;
                speakerObj.speakerTitle = session.Speaker_Faculty_Name_2_Title__c;
                speakerObjList.push(speakerObj);
            }

            if (session.Speaker_Faculty_Name_3__c) {
                let speakerObj = {};
                speakerObj.speakerName = session.Speaker_Faculty_Name_3__r.Name;
                speakerObj.speakerTitle = session.Speaker_Faculty_Name_3_Title__c;
                speakerObjList.push(speakerObj);
            }

            if (session.Speaker_Faculty_Name_4__r) {
                let speakerObj = {};
                speakerObj.speakerName = session.Speaker_Faculty_Name_4__r.Name;
                speakerObj.speakerTitle = session.Speaker_Faculty_Name_4_Title__c;
                speakerObjList.push(speakerObj);
            }

            if (session.Speaker_Faculty_Name_5__r) {
                let speakerObj = {};
                speakerObj.speakerName = session.Speaker_Faculty_Name_5__r.Name;
                speakerObj.speakerTitle = session.Speaker_Faculty_Name_5_Title__c;
                speakerObjList.push(speakerObj);
            }

            if (session.Speaker_Faculty_Name_6__r) {
                let speakerObj = {};
                speakerObj.speakerName = session.Speaker_Faculty_Name_6__r.Name;
                speakerObj.speakerTitle = session.Speaker_Faculty_Name_6_Title__c;
                speakerObjList.push(speakerObj);
            }

            data.Event_Sessions__r[i].speakersGroup = speakerObjList;

        }

    }

    createStartDateTimeOnSessions(data) {

        for (let i = 0; i < data.Event_Sessions__r.length; i++) {
            this.setStartEndDateTimes(data.Event_Sessions__r[i]);
        }

    }
    
    printError(error) {
        console.log("Error name", error.name);
        console.log("Error message", error.message);
        console.log("Error stack", error.stack);
    }
    

    groupSessionsByDay(sessions) {

        console.log('>> ENTRO EN groupSessionsByDay');

        let dateObjectList = this.getDatesOfAllSessions(sessions);
        let allSessionsGroupedAux = new Array();
        
        let dayNamesMap = new Map();
        dayNamesMap.set(0, 'Sunday');
        dayNamesMap.set(1, 'Monday');
        dayNamesMap.set(2, 'Tuesday');
        dayNamesMap.set(3, 'Wednesday');
        dayNamesMap.set(4, 'Thursday');
        dayNamesMap.set(5, 'Friday');
        dayNamesMap.set(6, 'Saturday');
        
        for (let j = 0; j < dateObjectList.length; j++) {
            
            let groupedSessions = {};
            let auxSessionList = new Array();
            let dateObject = dateObjectList[j];

            let year = dateObject.getFullYear().toString();
            let month = (dateObject.getMonth() + 1).toString();
            let day = dateObject.getDate().toString();

            if (month.length == 1) {
                month = '0' + month;
            }

            if (day.length == 1) {
                day = '0' + day;
            }

            let dateStr = year + '-' + month + '-' + day;

            for (let i = 0; i < sessions.length; i ++) {
                
                let currentSession = sessions[i];

                if (currentSession.Session_Date__c == dateStr) {
                    this.setStartEndDateTimes(currentSession);

                    if (currentSession.Link_To_Details__c) {
                        currentSession.hasLinkToDetails = true;
                    }

                    if (currentSession.Session_Time_Zone__c) {
                        currentSession.hasTimezone = true;
                    }

                    if (currentSession.Session_Venue_test__c) {
                        currentSession.hasVenue = true;
                    }

                    auxSessionList.push(currentSession);
                }

            }

            let weekDayName = dayNamesMap.get(dateObject.getDay());
            let groupName =  weekDayName + ' (' + dateObject.getDate() + ')';

            groupedSessions.groupName = groupName;
            groupedSessions.records = auxSessionList.sort((a, b) => a.customStartDateTime - b.customStartDateTime);
            
            allSessionsGroupedAux.push(groupedSessions);

        }

        console.log(allSessionsGroupedAux);

        this.allSessionsGrouped = allSessionsGroupedAux;
                   
    }

    setStartEndDateTimes(sessionObject) {
        sessionObject.customStartDateTime = new Date(sessionObject.Session_Date__c + ' ' + sessionObject.Session_Start_Time__c);
        sessionObject.customEndDateTime = new Date(sessionObject.Session_Date__c + ' ' + sessionObject.Session_End_Time__c);
        sessionObject.startTimeLocaleString = sessionObject.customStartDateTime.toLocaleString();
        sessionObject.endTimeLocaleString = sessionObject.customEndDateTime.toLocaleString();
    }

    getDatesOfAllSessions(sessions) {

        let dates = new Set();
        let dateObjects = new Array();

        sessions.forEach(element => {
            dates.add(element.Session_Date__c);
        });

        let dateStrArray = Array.from(dates);

        dateStrArray.forEach((dateStr) => {
            
            let gmtDateStr = dateStr + 'T00:00:00';
            let dateObject = new Date(gmtDateStr);
            dateObjects.push(dateObject);

        });

        dateObjects.sort((a, b) => a - b);

        return dateObjects;

    }

    millisecondsToTime(s){

        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
        return hrs + ':' + mins;

    }

    


    convertMillisecondsToHours(data) {

        for (let i = 0; i < data.Event_Sessions__r.length; i ++) {

            data.Event_Sessions__r[i].End_Time_Of_Session__c = this.millisecondsToTimeAMPM(data.Event_Sessions__r[i].End_Time_Of_Session__c);
            data.Event_Sessions__r[i].Start_Time_Of_Session__c = this.millisecondsToTimeAMPM(data.Event_Sessions__r[i].Start_Time_Of_Session__c);

        }

    }

    millisecondsToTimeAMPM(s) {

        let hoursMap = new Map();

        hoursMap.set('01', '01');
        hoursMap.set('02', '02');
        hoursMap.set('03', '03');
        hoursMap.set('04', '04');
        hoursMap.set('05', '05');
        hoursMap.set('06', '06');
        hoursMap.set('07', '07');
        hoursMap.set('08', '08');
        hoursMap.set('09', '09');
        hoursMap.set('10', '10');
        hoursMap.set('11', '11');
        hoursMap.set('12', '12');
        hoursMap.set('13', '01');
        hoursMap.set('14', '02');
        hoursMap.set('15', '03');
        hoursMap.set('16', '04');
        hoursMap.set('17', '05');
        hoursMap.set('18', '06');
        hoursMap.set('19', '07');
        hoursMap.set('20', '08');
        hoursMap.set('21', '09');
        hoursMap.set('22', '10');
        hoursMap.set('23', '11');
        hoursMap.set('23', '12');

        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;

        let amPm = '';
        if (hrs > 12) {
            amPm = 'PM';
        } else {
            amPm = 'AM';
        }

        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
                
        return hoursMap.get(String(hrs)) + ':' + mins + ' ' + amPm;

    }

    handleSectionClick(event) {

        let currentSecName = event.currentTarget.dataset.secname;
        let parentAccSelector = '.' + event.currentTarget.dataset.parentclass;
        let parentAccordion = this.template.querySelector(parentAccSelector);
        let prevSelection = parentAccordion.getAttribute('data-prevselection');
  
        if (currentSecName != prevSelection) {
  
          parentAccordion.activeSectionName = 'A';
          parentAccordion.setAttribute('data-prevselection', 'A');
  
        } else {
  
          parentAccordion.activeSectionName = 'D';
          parentAccordion.setAttribute('data-prevselection', 'D');
  
        }
  
    }

    validateUrlParameters() {

        let url = new URL(window.location.href);
        const urlParams = url.searchParams;
        let isValid = false;

        this.eventId = urlParams.get('c__eventId');

        if (this.eventId) {
            isValid = true;
        }

        return isValid;

    }

}