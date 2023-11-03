import { buildTextComponent } from './textComponent.js';
import { buildButtonComponent } from './buttonComponent.js';
import { buildImageComponent } from './imgComponent.js';
import { buildPlaceHolderComponent } from './placeHolderComponent.js';

function getElementFromType(elementType) {
    if (elementType === 'imagen') {
        return buildImageComponent();
    }
    if (elementType === 'texto') {
        return buildTextComponent();
    }
    if (elementType === 'boton') {
        return buildButtonComponent();
    }
    if (elementType === 'place holder') {
        return buildPlaceHolderComponent();
    }
}

function getHtmlAsText(htmlElement) {
    return htmlElement.outerHTML;
}

function mapPropertiesToAnotherObject(mapToObject, mapFromObject) {
    Object.keys(mapFromObject).forEach((key) => {
        mapToObject[key] = mapFromObject[key]
    });
}

const componentBuilder = {
    htmlElemntsArray : [],
    buildPlaceHoldersArray: function () {
        const tempArray = [];
        for (let i = 0; i < 5; i++) {
            tempArray.push(getElementFromType('place holder'))
        }
        this.htmlElemntsArray = tempArray;
    },
    buildFromArray: function (baseArray) {
        const tempArray = baseArray.map(element => {
            
            const baseElement = getElementFromType(element.type);
            const completeElement = {
                ...baseElement,
                ...element
            }

            //es importante guardar las key de las cuales el indexGenerator en commonLogic lleva la cuenta
            completeElement.key = baseElement.key;
            
            return completeElement;
        });
        this.htmlElemntsArray = tempArray;
    },
    getHtmlElemntsArray: function () {
        //para ir tranca con el framework, la idea es que despues de cada update
        //pueda venir aca a generar un nuevo array para el estado de los componentes
        const tempArray = this.htmlElemntsArray.map(thisComponentObject => { return { ...thisComponentObject } })
        return tempArray;
    },
    changePropertyToElementByKey: function (key, propertyObject) {
        const elementToMutate = this.htmlElemntsArray.find(thisComponentObject => { return thisComponentObject.key === key })
        mapPropertiesToAnotherObject(elementToMutate, propertyObject);
    },
    changePropertyToElementIfSelected: function (propertyObject) {
        const elementToMutate = this.htmlElemntsArray.find(thisComponentObject => { return thisComponentObject.imSelected })
        mapPropertiesToAnotherObject(elementToMutate, propertyObject);
    },
    changePropertyToAll: function (propertyObject) {
        this.htmlElemntsArray.forEach(thisComponentObject => {
            mapPropertiesToAnotherObject(thisComponentObject, propertyObject);
        });
    },
    replaceElementSelected: function (type) {
        const indexOfSelectedComponent = this.htmlElemntsArray.findIndex(thisComponent => thisComponent.imSelected);
        if (indexOfSelectedComponent === -1) return -1;

        const newComponent = getElementFromType(type);

        this.htmlElemntsArray.splice(indexOfSelectedComponent, 1, newComponent);

        return newComponent.key;
    },
    replaceElementByKey: function (key, type) {
        const indexOfElementByKey = this.htmlElemntsArray.findIndex(thisComponent => thisComponent.key === key);
        if (indexOfElementByKey === -1) return -1;

        const newComponent = getElementFromType(type);

        this.htmlElemntsArray.splice(indexOfElementByKey, 1, newComponent);

        return newComponent.key;
    },
    getSelectedType: function () {
        return this.htmlElemntsArray.find(thisComponentObject => { return thisComponentObject.imSelected }).type
    }
};


export { getHtmlAsText, componentBuilder };