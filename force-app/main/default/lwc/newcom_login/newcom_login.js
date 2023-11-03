import { LightningElement, track, wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import communityLogin from '@salesforce/apex/CommunityAuthController.communityLogin';

export default class Newcom_login extends LightningElement {
    @track prosumia_logo;
    @track error_icon;
    @track visibility_icon;
    @track hide_icon;
    @track show_icon;
    @track passwordInput;
    @track showText = false;

    @track urlString;
    @track pageURL;

    @track username;
    @track password;
    @track errorCheck;
    @track errorMessage;

    connectedCallback() {
        var meta = document.createElement("meta");
        meta.setAttribute("name", "viewport");
        meta.setAttribute("content", "width=device-width, initial-scale=1.0");
        document.getElementsByTagName('head')[0].appendChild(meta);

        this.urlString = window.location.href;
        this.pageURL = this.urlString.substring(0,this.urlString.indexOf("/s/")+2);
        // console.log('url: ' + this.urlString);
        // console.log('url: ' + this.pageURL);

        this.prosumia_logo = RESOURCES + '/SALESFORCE/img/prosumia_logo.png';
        this.error_icon = RESOURCES + '/SALESFORCE/img/login/login-error.svg';
        this.show_icon = RESOURCES + '/SALESFORCE/img/login/login-viewpass.svg';
        this.hide_icon = RESOURCES + '/SALESFORCE/img/login/login-notviewpass.svg';
    }

    handleUserNameChange(event){
        this.username = event.target.value;
    }

    handlePasswordChange(event){
        this.password = event.target.value;
    }

    handleLogin(event){
        if(this.username && this.password){
        event.preventDefault();
        communityLogin({ 
            username: this.username, 
            password: this.password,
            startUrl: this.pageURL })
            .then((result) => {
                location.href = result;
            })
            .catch((error) => {
                this.error = error;      
                this.errorCheck = true;
                this.errorMessage = error.body.message;
            });
        }
    }

    togglePassword() {
        this.passwordInput = this.template.querySelector('.pass-input');
        this.visibility_icon = this.template.querySelector('.eyeIcon');
        
        if (this.passwordInput.type === 'password') {
            this.passwordInput.type = 'text';
            this.visibility_icon.src = this.hide_icon;
        } else {
            this.passwordInput.type = 'password';
            this.visibility_icon.src = this.show_icon;
        }
    } 
}