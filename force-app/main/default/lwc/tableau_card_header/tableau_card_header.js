import { LightningElement, api } from 'lwc';

export default class Tableau_card_header extends LightningElement {
@api linePosition;
@api lineColor;
@api lineHeight;

@api text;

@api paddingLeft;
@api backgroundColor;
@api borderTopRadius;

renderedCallback(){
    const headerContainer = this.template.querySelector('div.headerContainer');
    headerContainer.style.backgroundColor = this.backgroundColor;
    headerContainer.style.paddingLeft = this.paddingLeft;
    headerContainer.style.borderTopLeftRadius = this.borderTopRadius;
    headerContainer.style.borderTopRightRadius = this.borderTopRadius;

    const textContainer = document.createElement('div');
    textContainer.innerText = this.text;

    textContainer.classList.add('textContainer');

    headerContainer.appendChild(textContainer);

    if (this.linePosition === 'Bottom') {
        textContainer.style.borderBottomStyle = 'solid';
        textContainer.style.borderBottomColor = this.lineColor;
        textContainer.style.borderBottomWidth = this.lineHeight;
    }
    if(this.linePosition === 'Top'){
        const lineDiv = document.createElement('div');
        lineDiv.style.backgroundColor = this.lineColor;
        lineDiv.style.height = this.lineHeight;
        lineDiv.style.position = 'absolute';
        lineDiv.style.top = '0';
        lineDiv.style.left = '15px';
        lineDiv.style.width = '45px';
        
        headerContainer.appendChild(lineDiv);
    }

}



}