import { LightningElement } from 'lwc';

export default class Communities_citizenSearchDummy extends LightningElement {
    connectedCallback() {
        document.querySelector(".search-bar-container").style.display = "";
        document.querySelector("#header-extension").style.display = "none";
        document.querySelector("#parent-div-search-super-m").style.display = "";
    }
}