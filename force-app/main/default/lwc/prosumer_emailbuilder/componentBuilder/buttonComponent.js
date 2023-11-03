import { indexGenerator, createWrapperDiv } from './commonLogic.js';

function buildButtonComponent() {
    const buttonComponentObject = {
        getHtmlElemnt() {
            const wrapperDiv = createWrapperDiv();

            const buttonElement = document.createElement("a");
            
            buttonElement.style.backgroundColor = "#0070d2";
            buttonElement.style.color = "#FFF"
            buttonElement.style.border = "1px solid transparent";
            buttonElement.style.borderRadius = "4px";
            buttonElement.style.padding = "7px 25px";
            buttonElement.style.cursor = "pointer";
            buttonElement.style.textDecoration= "none";

            buttonElement.innerText = this.etiquetaBoton;
            buttonElement.target = '_blank';
            buttonElement.href = this.urlBoton


            wrapperDiv.appendChild(buttonElement);
        
            return wrapperDiv;
        },
        key: indexGenerator.getNewIndex(),
        imSelected: false,
        type: 'boton',
        //default
        etiquetaBoton: 'Boton!',
        urlBoton: 'https://argentina--dev.sandbox.lightning.force.com/lightning/r/ContentDocument/069Da000002AWjKIAW/view'
    }

    return buttonComponentObject;
}

export { buildButtonComponent };