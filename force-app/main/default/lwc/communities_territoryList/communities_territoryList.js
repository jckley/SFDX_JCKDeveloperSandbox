import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import retrieveRootTerritory from '@salesforce/apex/TerritoryListController.retrieveRootTerritory'
import lblTerritory from '@salesforce/label/c.Territory';
import lblLevel from '@salesforce/label/c.AdministrativeLevel';
import { fireEvent } from 'c/pubsub';

export default class Communities_territoryList extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @track title = '';
    @track subtitle = '';
    @track arrTerritory = [1,2,3,4];

    @wire(retrieveRootTerritory)
    wiredRetrieveRootTerritory(objResult) {
        if(objResult !== undefined && objResult !== null && objResult.data !== undefined && objResult.data !== null) {
            this.title =  objResult.data.Name;
            this.subtitle =  lblTerritory + ' / ' + lblLevel + ' ' +  objResult.data.Level;

            console.log('title: ' + this.title);
            console.log('subtitle: ' + this.subtitle);
            console.log(`objResult.data.Id: ${objResult.data.Id}`);
            console.log(`objResult.data.Level: ${objResult.data.Level}`);

            fireEvent(this.pageRef, 'territorySelected', { 'parentid' : objResult.data.Id , 'level' : (objResult.data.Level + 1)} );
        }
    }

    renderedCallback() { 
        Promise.all([
            loadScript(this, 'https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'),
            loadStyle(this, 'https://fonts.googleapis.com/icon?family=Material+Icons'),
            loadStyle(this, 'https://fonts.googleapis.com/css?family=Roboto:regular,bold,medium'),
        ])          
    }

    // SELECT Name, Level0Name__c, Level1Name__c, Level2Name__c, Level3Name__c FROM Territorio_Administrativo__c WHERE Level0Name__c = 'Argentina'
            
    // @track newheight = document.querySelector(window).height() - document.querySelector('#page-header-title').height() - document.querySelector('#page-header-subtitle').height() - 100;
    // document.querySelector('.tree-card').style.height(newheight);
    // document.querySelector('#backgroud-div').style.height(newheight);
    // ter1 = '{!territory1selected}';
    // ter2 = '{!territory2selected}';
    // ter3 = '{!territory3selected}';
    // if(ter1 != ''){
    //     document.querySelector('#1content').scrollTop($('#' + ter1).position().top - 200);
    // }
    // if(ter2 != ''){
    //     document.querySelector('#2content').scrollTop($('#' + ter2).position().top - 200);
    // }
    // if(ter3 != ''){
    //     document.querySelector('#3content').scrollTop($('#' + ter3).position().top - 200);
    // }
    // var totalwidth = document.querySelector(document).width();
    // var left = document.querySelector(document).outerWidth() - document.querySelector(window).width();
    // var newwidth = document.querySelector(document).width() - 105;
    // if(document.querySelector('#backgroud-div').width() < newwidth){
    //     document.querySelector('#backgroud-div').width(newwidth);
    //     document.querySelector('body, html').width(totalwidth);
    //     document.querySelector('body, html').scrollLeft(left);
    // }

    // sforce.connection.sessionId = '{!$Api.Session_ID}';
    
    // function navigateToTerritory(Id, event, parentId, territoryLevel){
    //     window.location.href = '/lightning/r/Territorio_Administrativo__c/' + Id + '/view';

    // }

    // function seeChilds(Id, levelnumber, parentId){
    //     var selectedItems = document.querySelector('.selected-item');
    //     if(selectedItems.length > 0){
    //         selectedItems.each(function(item) {
    //             if(document.querySelector(this).parent().attr("id").substring(0,1)*1 >= (levelnumber)){
    //                 document.querySelector(this).removeClass('selected-item');
    //             }
    //         });
    //     }
    //     for (i = (levelnumber + 1); i < 5; i++){
    //         document.querySelector('#' + i +'card').hide();
    //     }
    //     document.querySelector('#' + (levelnumber + 1) +'card').hide();
    //     childTerritories = sforce.apex.execute("TerritoryHierarchyController","getChildTerritories",{territoryId:Id, parentId:parentId});
    //     childTerritories = JSON.parse(childTerritories);
    //     document.querySelector('#' + Id).addClass('selected-item');
    //     if(childTerritories.length > 0){
    //         createTerritoryCardHTML(childTerritories, levelnumber);
    //     }
    // }

    // function createTerritoryCardHTML(childTerritories, territoryLevel){
    //     var htmlGrandChilds = '';
    //     htmlGrandChilds +='<div id="' + (territoryLevel + 1) + 'card" class="card-top-margin pl-0 pr-0">';
    //     htmlGrandChilds +=  '<div id="' + (territoryLevel + 1) + 'card-content" class="card tree-card" onclick="focusCard(' + (territoryLevel + 1) + ');"';
    //     htmlGrandChilds +=  (territoryLevel + 1) == 4 ? 'style="margin-right: 60px;">' : '>';
    //     htmlGrandChilds +=      '<div class="card-cont subattribute-header">';
    //     htmlGrandChilds +=          '<div class="subattribute-title">';
    //     htmlGrandChilds +=              '<span>{!$Label.AdministrativeLevel} ' + (territoryLevel + 1) + '</span>';
    //     htmlGrandChilds +=          '</div>';
    //     htmlGrandChilds +=      '</div>';
    //     htmlGrandChilds +=      '<div class="level-search-bar">';
    //     htmlGrandChilds +=          '<img class="search-icon" src="{!URLFOR($Resource.IconsPack1, 'searchps.svg')}"/>';
    //     htmlGrandChilds +=          '<input id="' + (territoryLevel + 1) + 'bar" type="text" onkeyup="filterTer(' + (territoryLevel + 1) + ');" placeholder="{!$Label.SearchTerritory}"/>';
    //     htmlGrandChilds +=          '<img id="' + (territoryLevel + 1) + 'clear" onclick="clearInput(' + (territoryLevel + 1) + ');" class="clear-icon" src="{!URLFOR($Resource.IconsPack1, 'closeemptyinputps.svg')}"/>';
    //     htmlGrandChilds +=      '</div>';
    //     htmlGrandChilds +=      '<div class="level-content">';
    //     htmlGrandChilds +=          '<div id="' + (territoryLevel + 1) + 'barlist" class="scrollable">';
    //     childTerritories.forEach(function(ter) {
    //         htmlGrandChilds +=          '<div onclick="javascript:seeChilds(' + "'" + ter.Id + "'" + ',' + (territoryLevel + 1) + ',' + "'" + ter.ParentId__c + "'" + ')" id="' + ter.Id + '" class="level-item">';
    //         htmlGrandChilds +=              '<div class="level-item-content">';
    //         htmlGrandChilds +=                  '<span class="level-item-text">' + ter.Name + '</span>';
    //         htmlGrandChilds +=                  '<div onclick="navigateToTerritory(' + "'" + ter.Id + "'" + ', event,' + "'" + ter.ParentId__c + "'" + ', ' + (territoryLevel + 1) + ');" class="level-item-text-hidden">{!$Label.SeeTerritory} <span><img class="search-icon" src="{!URLFOR($Resource.IconsPack1, 'arrowrightps.svg')}"/></span></div>';
    //         htmlGrandChilds +=              '</div>';
    //         htmlGrandChilds +=          '</div>';
    //     });
    //     htmlGrandChilds +=          '</div>';
    //     htmlGrandChilds +=      '</div>';
    //     htmlGrandChilds +=  '</div>';
    //     htmlGrandChilds +='</div>';
    //     $(htmlGrandChilds).insertAfter('#' + territoryLevel + 'card');
    //     var newheight = document.querySelector(window).height() - document.querySelector('#page-header-title').height() - $('#page-header-subtitle').height() - 100;
    //     var left = document.querySelector(document).outerWidth() - document.querySelector(window).width();
    //     var totalwidth = document.querySelector(document).width();
    //     document.querySelector('#' + territoryLevel + 'card-content').css({'margin-right':'0'});
    //     document.querySelector('#' + territoryLevel + 'card-no-content').hide();
    //     document.querySelector('#' + (territoryLevel +1) + 'card-no-content').show();
    //     document.querySelector('.tree-card').height(newheight);
    //     var newwidth = $(document).width() - 105;
    //     if(document.querySelector('#backgroud-div').width() < newwidth){
    //         document.querySelector('#backgroud-div').width(newwidth);
    //         document.querySelector('body, html').width(totalwidth);
    //         document.querySelector('body, html').scrollLeft(left);
    //     }
    // }
    
    // function filterTer(territoryLevel){
    //     var value = document.querySelector("#" + territoryLevel + "bar").val().toLowerCase();
    //     if(value != ''){
    //         document.querySelector('#' + territoryLevel + 'clear').show();
    //     }else{
    //         document.querySelector('#' + territoryLevel + 'clear').hide();
    //     }
    //     $("#" + territoryLevel + "barlist > div").filter(function() {
    //         document.querySelector(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    //     });
    // }

    // function clearInput(territoryLevel){
    //     var value = document.querySelector('#' + territoryLevel + 'bar').val('');
    //     filterTer(territoryLevel);
    // }

    // function focusCard(territoryLevel){
    //     var left = document.querySelector('#' + territoryLevel + 'card').position().left;
    //     document.querySelector('body, html').scrollLeft(left);
    // }

    // function backToLevel(territoryLevel){
    // }

    // document.querySelector(window).scroll(function(){
    //     if(document.querySelector(this).scrollTop > 0){
    //         document.querySelector('#header-container').css({'position':'static'});
    //     }
    // });
}