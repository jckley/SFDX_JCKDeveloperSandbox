import { indexGenerator, createWrapperDiv } from './commonLogic.js';

function buildPlaceHolderComponent() {
    return {
        getHtmlElemnt() {
            const wrapperDiv = createWrapperDiv();

            const textElement = document.createElement("h1");
            textElement.innerText = "+";

            wrapperDiv.appendChild(textElement);

            return wrapperDiv;
        },
        key: indexGenerator.getNewIndex(),
        imSelected: false,
        type: 'place holder',
    }
}

export { buildPlaceHolderComponent };