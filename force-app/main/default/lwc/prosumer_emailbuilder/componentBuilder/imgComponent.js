import { indexGenerator, createWrapperDiv } from './commonLogic.js';

function buildImageComponent() {
    const textComponentObject = {
        getHtmlElemnt() {
            const wrapperDiv = createWrapperDiv();

            const imgElemnt = document.createElement("img");
            imgElemnt.src = this.imageSrc;
        
            wrapperDiv.appendChild(imgElemnt);
        
            return wrapperDiv;
        },
        key: indexGenerator.getNewIndex(),
        imSelected: false,
        type: 'imagen',
        //default
        imageSrc: 'https://placehold.co/600x400/png'
    }

    return textComponentObject;
}

export { buildImageComponent };