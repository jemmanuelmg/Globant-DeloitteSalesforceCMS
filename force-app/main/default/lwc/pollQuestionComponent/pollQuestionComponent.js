import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setVote from '@salesforce/apex/PollsController.setVote';
import getUser from "@salesforce/apex/PollsController.getUser";

export default class PollQuestionComponent extends LightningElement {

    @api recordId;
    @api question;
    @track voted;

    user;
    currentSelectedAnswer;
    currentQuestion;

    firstLoad = true;

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

    async connectedCallback() 
    {   
        if(this.firstLoad)
        {
            await this.fetchUser();

            this.firstLoad = false;
        }
    }

    async voteHandler(event)
    {
        event = this.stopDefaultActions(event);

        try
        {
            this.voted = await setVote({
                userId:this.user.Id,
                questionId: this.currentQuestion,
                answerId: this.currentSelectedAnswer,
                pollId: this.recordId
            });

            this.showToast('Success', 'Vote saved successfully', 'success');

            const reloadEvent = new CustomEvent('reloadrequest');
            this.dispatchEvent(reloadEvent);
            
        }
        catch(error)
        {
            console.error("Error voteHandler:");
            console.error(error);
        }

    }

    answerHandler(event)
    {
        event = this.stopDefaultActions(event);

        const options = this.template.querySelectorAll("label");

        const target = event.target;

        this.currentSelectedAnswer = target.dataset.id;

        this.currentQuestion = target.dataset.question;

        for (let j = 0; j < options.length; j++)
        {
            if(options[j].classList.contains("selected"))
            {
                options[j].classList.remove("selected");
            }
        }
        
        target.classList.add("selected");
        
        let forVal = target.getAttribute("for");
        let selectInput = this.template.querySelector("#"+forVal);
        let getAtt = selectInput.getAttribute("type");

        if(getAtt == "checkbox")
        {
            selectInput.setAttribute("type", "radio");
        }
        else if(selectInput.checked == true)
        {
            target.classList.remove("selected");

            selectInput.setAttribute("type", "checkbox");
        }

        let array = [];


        for (let l = 0; l < options.length; l++)
        {
            if(options[l].classList.contains("selected"))
            {
                array.push(l);
            }
        }

        if(array.length == 0)
        {
            for (let m = 0; m < options.length; m++)
            {
                options[m].removeAttribute("class");
            }
        }

        return false;
    }

    radioHandler(event)
    {
        event = this.stopDefaultActions(event);
    }

    stopDefaultActions(event)
    {
        event.preventDefault();
        event.stopPropagation();

        return event;
    }

    showToast(title, message, variant) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: title, 
                message: message, 
                variant: variant,
                mode: 'pester'
            })
        );

    }
}