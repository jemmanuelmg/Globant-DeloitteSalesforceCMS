import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import fontawesome from '@salesforce/resourceUrl/fontawesome';
import getFlagEnableFavorites from '@salesforce/apex/ArticleShareAndAddFavoriteCrontroller.getFlagEnableFavorites';
import isArticleAddedAsFavorite from '@salesforce/apex/ArticleShareAndAddFavoriteCrontroller.isArticleAddedAsFavorite';
import deleteFavoriteArticle from '@salesforce/apex/ArticleShareAndAddFavoriteCrontroller.deleteFavoriteArticle';
import insertNewFavoriteArticle from '@salesforce/apex/ArticleShareAndAddFavoriteCrontroller.insertNewFavoriteArticle';


export default class ArticleShareAndAddFavorite extends LightningElement {

    @track articleTitle;
    @track articleNumber;
    @track articleUrl;
    @track twitterShareLink;
    @track linkedinShareLink;
    @track isFavorite;
    @track enableFavorites;
    @track isLoading;
    @track addToFavText;
    @track removeFromFavText;
    @api menuLanguage;

    @wire(CurrentPageReference)
    pageRef;

    renderedCallback() {

        Promise.all([
            loadScript(this, fontawesome + '/fontawesome/fontawesome.js')
        ])
        .then(() => {
            this.initializeShareIcon();
        })
        .catch(error => {
            console.log('Error at renderedCallback loading JSSocial Assets');
            this.printError(error);
        });

    }

    connectedCallback() {

        console.log('>>>> Entered in connectedCallback');
        try {
            this.extractArticleDetails();
            this.createShareLinks();
            this.getFlagEnableComponent();
        } catch(error) {
            console.log('Error in ConnectedCallback()');
            this.printError(error);
        }

    }

    getFlagEnableComponent() {

        getFlagEnableFavorites()
        .then((flag) => {

            if (flag == true) {
                this.enableFavorites = true;
                this.getIsArticleAddedAsFavorite();
                this.stablishLanguage();
            } else {
                this.enableFavorites = false;
            }

        })
        .catch(error => {
            console.log('Error on getFlagEnableFavorites()');
            this.printError(error);
        });
        
    }

    stablishLanguage() {

        if (this.menuLanguage == 'English' || !this.menuLanguage) {

            this.addToFavText = 'Add to favorites';
            this.removeFromFavText = 'Remove from Favorites';


        } else if (this.menuLanguage == 'French') {

            this.addToFavText = 'Ajouter aux Favoris';
            this.removeFromFavText = 'Retirer des favoris';

        } else if (this.menuLanguage == 'Chinese') {

            this.addToFavText = '添加到收藏夹';
            this.removeFromFavText = '从收藏夹中删除';

        }

    }

    getIsArticleAddedAsFavorite() {

        let articleCode = this.articleNumber;

        isArticleAddedAsFavorite({articleCode : articleCode})
        .then((flag) => {
            
            if (flag == true) {
                this.isFavorite = true;
            } else {
                this.isFavorite = false;
            }

        })
        .catch(error => {
            console.log('Error on getFlagEnableFavorites()');
            this.printError(error);
        });
    }

    addOrRemoveFromFavorites() {
       
        this.isLoading = true;
        let articleCodeParam = this.articleNumber;
        let articleTitleParam = this.articleTitle;
        let articleUrlParam = this.articleUrl;

        if (this.isFavorite == true) {

            deleteFavoriteArticle({articleCode : articleCodeParam})
            .then(() => {
            
                this.showToast('Success', 'Removed from favorites', 'info');
                this.isFavorite = false;
                this.isLoading = false;
            
            })
            .catch(error => {
                console.log('Error on deleteFavoriteArticle()');
                this.printError(error);
                this.isLoading = false;
            });

        } else {

            insertNewFavoriteArticle({articleCode : articleCodeParam, articleTitle : articleTitleParam, articleUrl : articleUrlParam})
            .then(() => {
            
                this.showToast('Success', 'Added to favorites', 'success');
                this.isFavorite = true;
                this.isLoading = false;
            
            })
            .catch(error => {
                console.log('Error on insertNewFavoriteArticle()');
                this.printError(error);
                this.isLoading = false;
            });

        }

    }

    initializeShareIcon() {
        console.log('$$$ Font awesome initialized correctly');
    }

    extractArticleDetails() {

        let pageUrl = window.location.href;
        let articleTitle = this.getArticleTitle(pageUrl);
        let articleNumber = this.getArticleContentKey(pageUrl);

        this.articleTitle = articleTitle;
        this.articleNumber = articleNumber;
        this.articleUrl = pageUrl;

    }

    getArticleTitle(pageUrl) {

        let articleContentKey = this.getArticleContentKey(pageUrl);
        let textBeforeTitle = pageUrl.substring(0, pageUrl.indexOf('article/') + 8);
        pageUrl = pageUrl.replace(textBeforeTitle, '');
        pageUrl = pageUrl.replace('-' + articleContentKey, '');
        pageUrl = pageUrl.replace('?language=en_US', '');
        pageUrl = pageUrl.replace('?language=fr', '');
        pageUrl = pageUrl.replace('?language=zh_CN', '');
        pageUrl = pageUrl.replace(/-/g, ' ');
        let articleTitle = this.capitalizeFirstLetterOfWords(pageUrl);
        return articleTitle;

    }

    getArticleContentKey(pageUrl) {

        let textBeforeTitle = pageUrl.substring(0, pageUrl.indexOf('article/') + 8);
        pageUrl = pageUrl.replace(textBeforeTitle, '');
        pageUrl = pageUrl.replace('?language=en_US', '');
        pageUrl = pageUrl.replace('?language=fr', '');
        pageUrl = pageUrl.replace('?language=zh_CN', '');
        let articleNumber = pageUrl.substring(pageUrl.length - 28, pageUrl.length);
        return articleNumber;

    }

    createShareLinks() {

        let articleTitleScaped = this.escapeTextToUrl(this.articleTitle);
        let twitterShareLink = 'https://twitter.com/intent/tweet?text=' + articleTitleScaped + '%20%23DeloitteCFOLens' + '%20' + this.articleUrl;
        this.twitterShareLink = twitterShareLink;

        let linkedinShareLink = 'https://www.linkedin.com/sharing/share-offsite/?url=' + this.articleUrl;
        this.linkedinShareLink = linkedinShareLink;

        console.log('$$$ The final twitter link');
        console.log(twitterShareLink);
    }

    escapeTextToUrl(text) {

        text = text.replace(/:/g, '%3A');        
        return encodeURI(text) ;
    }


    capitalizeFirstLetterOfWords(words) {

        var separateWord = words.toLowerCase().split(' ');
        for (var i = 0; i < separateWord.length; i++) {
            separateWord[i] = separateWord[i].charAt(0).toUpperCase() +
            separateWord[i].substring(1);
        }
        
        return separateWord.join(' ');
    
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

}