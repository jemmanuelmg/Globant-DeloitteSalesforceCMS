import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllFavoriteArticles from '@salesforce/apex/ArticleShareAndAddFavoriteCrontroller.getAllFavoriteArticles';

export default class ListFavoriteArticlesCFOLens extends NavigationMixin(LightningElement) {

    @track articleList = [];
    @track isLoading;
    @track favoritesExists;
    @track noFavTitle;
    @track noFavMessage;
    @api menuLanguage;

    connectedCallback() {

        this.isLoading = true;

        getAllFavoriteArticles()
        .then((data) => {
                        
            data = JSON.parse(JSON.stringify(data));

            if (data.length > 0) {
                this.favoritesExists = true;
            }

            this.articleList = this.normalizeFieldsOnData(data);
            this.isLoading = false;

            this.stablishLanguage();

        })
        .catch(error => {
            console.log('Error on getFlagEnableFavorites()');
            this.printError(error);
            this.isLoading = false;
        });

    }

    normalizeFieldsOnData(data) {
        let currentData = [];
        let i = 0;
        data.forEach((row) => {
            let rowData = {};
            rowData.id = row.Id;
            rowData.createdDate = row.CreatedDate;
            rowData.addedOn = (new Date(row.CreatedDate)).toLocaleString();
            rowData.url = row.Article_URL__c;
            rowData.title = row.Article_Title__c;
            currentData.push(rowData);
        });

        return currentData;    
    }

    stablishLanguage() {

        if (this.menuLanguage == 'English' || !this.menuLanguage) {

            this.noFavTitle = 'No favorites found.';
            this.noFavMessage = 'Add some articles to your favorites list by clicking on \'Add to Favorites\' at the top of the window.';


        } else if (this.menuLanguage == 'French') {

            this.noFavTitle = 'Aucun favori trouvé.';
            this.noFavMessage = 'Ajoutez quelques articles à votre liste de favoris en cliquant sur «Ajouter aux favoris» en haut de la fenêtre.';

        } else if (this.menuLanguage == 'Chinese') {

            this.noFavTitle = '找不到收藏夹。';
            this.noFavMessage = '通过单击窗口顶部的“添加到收藏夹”，将一些文章添加到收藏夹列表中。';

        }

    }

    navigateToArticle(event) {

        event.preventDefault();
        let articleUrl = event.currentTarget.dataset.articleurl;
        articleUrl = articleUrl.replace('https://cfolens.deloitte.com', '');

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: articleUrl
            },
        });


    }

}