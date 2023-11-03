import { indexGenerator, createWrapperDiv } from './commonLogic.js';

function buildTextComponent() {
    const textComponentObject = {
        getHtmlElemnt() {
            const wrapperDiv = createWrapperDiv();

            const textElement = document.createElement("p");
            textElement.innerText = this.contenidoDelTexto;

            wrapperDiv.appendChild(textElement);

            return wrapperDiv;
        },
        key: indexGenerator.getNewIndex(),
        imSelected: false,
        type: 'texto',
        //default
        contenidoDelTexto: 'esto es un texto!'
    }

    return textComponentObject;
}

export { buildTextComponent };