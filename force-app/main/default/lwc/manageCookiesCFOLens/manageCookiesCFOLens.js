import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ManageCookiesCFOLens extends LightningElement {

    @track showModal = false;
    @track mainButtonLabel;
    @track modalContent;
    @track cancelBtnLabel;
    @track acceptBtnLabel;
    @track isLoading = false;
    @api menuLanguage;

    connectedCallback() {
        this.loadTranslatedTexts(this.menuLanguage);
    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    loadTranslatedTexts(language) {
        if (language == 'English') {

            this.mainButtonLabel = 'Manage Cookies';
            this.modalContent = 'CFO Lens uses cookies to offer you a personalized experience. This information is used privately and is not shared. Do you want to delete all the cookies from your device?';
            this.acceptBtnLabel = 'Accept';
            this.cancelBtnLabel = 'Cancel';

        } else if (language == 'French') {

            this.mainButtonLabel = 'Gérer les cookies';
            this.modalContent = 'CFO Lens utilise des cookies pour vous offrir une expérience personnalisée. Ces informations sont utilisées en privé et ne sont en aucun cas partagées. Voulez-vous supprimer tous les cookies de votre appareil?';
            this.acceptBtnLabel = 'J\'accepte';
            this.cancelBtnLabel = 'Annuler';

        } else if (language == 'Chinese') {

            this.mainButtonLabel = '管理 Cookie';
            this.modalContent = 'CFO Lens使用cookie为您提供个性化的体验。 此信息仅供私人使用，不以任何方式共享。 您要删除设备中的所有cookie吗？';
            this.acceptBtnLabel = '接受';
            this.cancelBtnLabel = '取消';

        }
    }

    deleteCookies() {
        this.deleteCookie('OptanonConsent');
        this.deleteCookie('OptanonAlertBoxClosed');
        this.deleteCookie('CookieConsentPolicy');
        this.showToast('Success', 'All cookies has been removed from your device', 'success');
        this.closeModal();
        this.isLoading = false;        
    }

    deleteCookie(cname) {
        document.cookie = cname + "=;" + 'expires=Thu, 01-Jan-70 00:00:01 GMT;' + "path=/;" + 'domain=.cfolens.deloitte.com';
        document.cookie = cname + "=;" + 'expires=Thu, 01-Jan-70 00:00:01 GMT;' + "path=/;" + 'domain=cfolens.deloitte.com';
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