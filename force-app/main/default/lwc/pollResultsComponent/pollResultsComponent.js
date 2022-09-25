import { LightningElement, api } from 'lwc';

export default class PollResultsComponent extends LightningElement 
{
    @api recordId;
    @api question;

    isFirstLoad = true;

    setupForLocalTesting()
    {
        // properties for testing purpose
        // override this when is needed

        this.recordId = 'a3h0n000000BT13AAG';
    }

    renderedCallback() 
    {   
        if(this.isFirstLoad)
        {
            // this.setupForLocalTesting();

            this.processProgressBar();

            this.showPollResultProgress();

            this.isFirstLoad = false;
        }
    }

    showPollResultProgress()
    {
        const options = this.template.querySelectorAll("label");

        let forVal, selectInput, getAtt;

        let array = [];

        for (let j = 0; j < options.length; j++)
        {
            if(!options[j].classList.contains("selected"))
            {
                options[j].classList.add("selected");
            }

            options[j].classList.add("selectall");

            forVal = options[j].getAttribute("for");
            selectInput = this.template.querySelector("#"+forVal);
            getAtt = selectInput.getAttribute("type");

            if(getAtt == "checkbox")
            {
                selectInput.setAttribute("type", "radio");
            }
            else if(selectInput.checked == true)
            {
                target.classList.remove("selected");

                selectInput.setAttribute("type", "checkbox");
            }
        }

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

    answerHandler(event)
    {
        event = stopDefaultActions(event);
    }

    processProgressBar()
    {
        const progressBars = this.template.querySelectorAll(".progress-bar");

        progressBars.forEach((element,i) =>{
            element.style.setProperty('--progressPercent', this.question.answers[i].percent);
            const customProperty = getComputedStyle(element).getPropertyValue('--progressPercent');
        });
    }

    stopDefaultActions(event)
    {
        event.preventDefault();
        event.stopPropagation();

        return event;
    }
}