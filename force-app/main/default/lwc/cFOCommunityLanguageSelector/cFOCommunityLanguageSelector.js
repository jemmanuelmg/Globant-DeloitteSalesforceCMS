import { LightningElement, track, wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFlagEnableComponent from '@salesforce/apex/CFOLanguageSelectorController.getFlagEnableComponent';
import updateCountryLanguage from '@salesforce/apex/CFOLanguageSelectorController.updateCountryLanguage';

export default class CFOCommunityLanguageSelector extends NavigationMixin(LightningElement) {
    
    @track isLoading = false;
    @track isLoadingModal = false;
    @track enableComponent;
    @track componentTitle;
    @track compDisabledText;
    @track comboLabel;
    @track comboLabel2;
    @api menuLanguage;
    @track languagesAvailable = [];
    @track showModal = false;
    @track confirmationText;
    @track acceptBtnLabel;
    @track cancelBtnLabel;

    @track contriesAndLanguagesMap = new Map([
        ['United States', 
            [
                {label : 'English', value : 'English'}
            ]
        ],
        
        ['Canada', 
            [
                {label : 'English', value : 'English'},
                {label : 'French (Français)', value : 'French'}
            ]
        ],
        
        ['China', 
            [
                {label : 'English', value : 'English'},
                {label : 'Chinese (中国人)', value : 'Chinese'}
            ]
        ],
        
        ['South Africa', 
            [
                {label : 'English', value : 'English'}
            ]
        ]
    ]);

    get countryOptions() {
        return [
            { label: 'United States (USA)', value: 'United States' },
            { label: 'Canada', value: 'Canada' },
            { label: 'China (中国)', value: 'China' },
            { label: 'South Africa (Iningizimu Afrika)', value: 'South Africa' }
        ];
    }

    connectedCallback() {

        this.loadTranslatedTexts(this.menuLanguage);

        getFlagEnableComponent()
        .then((flag) => {
            
            this.enableDisableComponentAccess(flag);
            
        })
        .catch((error) => {

            console.log('Error in connectedCallback() getFlagEnableComponent');
            this.printError(error);

        });

    }    

    enableDisableComponentAccess(flag) {

        if (flag === true) {
            this.enableComponent = true;
        } else {
            this.enableComponent = false;
        }

    }

    handleCountryChange(event) {

        let countryParam = event.detail.value;
        let returnedLanguages = this.contriesAndLanguagesMap.get(countryParam);
        this.languagesAvailable = [];
        for (let i = 0; i < returnedLanguages.length; i ++) {
            this.languagesAvailable = [...this.languagesAvailable, returnedLanguages[i]];
        }

    }
    

    changeLanguage(event) {
        
        this.isLoading = true;
        this.isLoadingModal = true;
        let languageParam = this.template.querySelector('.language-selector-input').value;
        let countryParam = this.template.querySelector('.country-selector-input').value;

        updateCountryLanguage({country : countryParam, language : languageParam})
        .then(() => {
            //this.redirectToLoginPage(languageParam);
            this.redirectToStandardLogout();
            this.isLoading = false;
        })
        .catch((error) => {
            this.isLoading = false;
            console.log('Error in changeLanguage() updateCFOPreferedLanguage');
            this.printError(error);
        });
        

    }

    redirectToLoginPage(language) {

        let loginPagelink = '/s/login/';
        
        if (language == 'English') {

            loginPagelink += '?language=en_US';


        } else if (language == 'French') {

            loginPagelink += '?language=fr';


        } else if (language == 'Chinese') {

            loginPagelink += '?language=zh_CN';

        }

        console.log(loginPagelink);
        this.navigateToPage(loginPagelink);

    }

    //Second method to logout someone is to redirect them to this link instead of deleting the AuthSession records of the user.
    //The retUrl is a parameter with the address that will appear after logging out
    //and the '/' character must be encoded as %2F
    //in this case if the domain included .force.com it means that is not a prod environment
    //and therefore it redirects to CFOProgram/s/login. Otherwise it redirects to
    //cfolens.deloitte.com/s/login
    redirectToStandardLogout() {
        console.log('Entered inide redirectToStandardLogout');
        let baseUrl = window.location.href;
        let domain = baseUrl.substring(8, baseUrl.indexOf('.com/') + 4);
        let url;

        if (baseUrl.includes('.force.com')) {
            url = "https://" + domain + "/secur/logout.jsp?retUrl=https%3A%2F%2F" + domain + "%2FCFOProgram%2Fs%2Flogin";
        } else {
            url = "https://" + domain + "/secur/logout.jsp?retUrl=https%3A%2F%2F" + domain + "%2Fs%2Flogin";
        }
        
        window.location.replace(url);
    }

    loadTranslatedTexts(language) {

        if (language == 'English') {

            this.componentTitle = 'Language Selector';
            this.compDisabledText = 'Please register to customize the language';
            this.comboLabel = 'Select a language';
            this.comboLabel2 = 'Select a Country';
            this.confirmationText = 'To continue, you must login again with your username and password for the changes to take effect. Do you want to continue?';
            this.acceptBtnLabel = 'Accept';
            this.cancelBtnLabel = 'Cancel';

        } else if (language == 'French') {

            this.componentTitle = 'Sélecteur de Langue';
            this.compDisabledText = 'Veuillez vous inscrire pour personnaliser la langue';
            this.comboLabel = 'Sélectionnez une langue';
            this.comboLabel2 = 'Choisissez un Pays';
            this.confirmationText = 'Pour continuer, vous devrez vous reconnecter pour que les modifications prennent effet. Voulez-vous continuer?';
            this.acceptBtnLabel = 'J\'accepte';
            this.cancelBtnLabel = 'Annuler';

        } else if (language == 'Chinese') {

            this.componentTitle = '语言选择器';
            this.compDisabledText = '请注册以自定义语言';
            this.comboLabel = '选择一种语言';
            this.comboLabel2 = '选择一个国家';
            this.confirmationText = '要继续，您将必须重新登录以使更改生效。 你要继续吗？';
            this.acceptBtnLabel = '接受';
            this.cancelBtnLabel = '取消';

        }

    }

    printError(error) {

        console.log("Error name", error.name);
        console.log("Error message", error.message);
        console.log("Error stack", error.stack);

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

    navigateToPage(urlParam) {

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: urlParam
            },
        });

    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

}