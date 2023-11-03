import { LightningElement, api } from 'lwc';
import prosumerFileInput from 'c/prosumer_fileinput_modal';

export default class Prosumer_emailbuilder_propertiesform extends LightningElement {
    _listofcomponents;
        
    @api 
    set listofcomponents (value){
        console.log('Set listofcomponents, se injectan variables desde afuera')
        this._listofcomponents = value;

        const selectedComponent = value.find(thisComponent=>thisComponent.imSelected === true);
        const imgSourceFromApi = selectedComponent?.type === 'imagen' ? selectedComponent.imageSrc : '';
        this.imgSrcForInput = imgSourceFromApi;
        this.imgSrc = imgSourceFromApi;
    }
    get listofcomponents () {
        return this._listofcomponents;
    }
    
    get selectedComponent () {
        return this.listofcomponents.find(thisComponent=>thisComponent.imSelected === true);
    }
    
    get selectedValues () {
        return {
            textoSelected: this.selectedComponent?.type === 'texto',
            botonSelected: this.selectedComponent?.type === 'boton',
            imagenSelected: this.selectedComponent?.type === 'imagen',
        }
    }

    get editableComponentSelected () {
        return (this.selectedComponent && this.selectedComponent?.type !== 'place holder')
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    get textInputInitialValue () {
        const intialTextValue = this.selectedComponent?.type === 'texto' ? this.selectedComponent.contenidoDelTexto : '';
        this.textValue = intialTextValue;
        return intialTextValue;
    }

    textValue;
    handleTextContentChange (event) {
        this.textValue = event.detail.value;
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    get buttonLabelInputInitialValue () {
        const intialButtonLabel = this.selectedComponent?.type === 'boton' ? this.selectedComponent.etiquetaBoton : '';
        this.buttonLabel = intialButtonLabel;
        return intialButtonLabel;
    }

    buttonLabel;
    handleButtonLabelChange (event) {
        this.buttonLabel = event.detail.value;
    }

    get buttonUrlInputInitialValue () {
        const intialButtonUrl = this.selectedComponent?.type === 'boton' ? this.selectedComponent.urlBoton : '';
        this.buttonUrl = intialButtonUrl;
        return intialButtonUrl;
    }

    buttonUrl;
    handleButtonUrlChange (event) {
        this.buttonUrl = event.detail.value;
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------

    /*
    get imgSrcInputInitialValue () {
        console.log('se llama a imgSrcInputInitialValue');
        const intialImgSrc = this.selectedComponent?.type === 'imagen' ? this.selectedComponent.imageSrc : '';
        this.imgSrc = intialImgSrc;
        return intialImgSrc;
    }
    */

    //imgSrcForInput, deberia cambiar siempre que se inyecte un nuevo array al componente (desde @api), y cuando se carga un file
    imgSrcForInput;

    //debe cambiar siempre, teniendo la info mas actualizada
    imgSrc;

    handleImgSrcChange (event) {
        this.imgSrc = event.detail.value;
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------
    handleGuardar(){
        const payload = {
            textValue:this.textValue,
            buttonLabel:this.buttonLabel,
            buttonUrl:this.buttonUrl,
            imgSrc:this.imgSrc
        }

        const changepropertyevent = new CustomEvent('changeproperty', { detail: payload });
        this.dispatchEvent(changepropertyevent);
    }

    renderedCallback () {
        console.log('debug renderedCallback')
    }

    async handleGestorArchivos() {
        const result = await prosumerFileInput.open({
            size: 'large',
            label: 'Modal Seleccionar Accion',
            filestypes: ['.jpeg', '.jpg']
        });
        if(!result) return;
        console.log('result???' , result)
        this.imgSrcForInput = result.contentDownloadUrl;
        this.imgSrc = result.contentDownloadUrl;
        this.handleGuardar();
    }

}