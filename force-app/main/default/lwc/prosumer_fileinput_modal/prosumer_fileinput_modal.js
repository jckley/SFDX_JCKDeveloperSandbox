import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import createLinkForContentVersionId from '@salesforce/apex/Prosumer_fileinput_modal_Controller.createLinkForContentVersionId';
import deleteFileWithContentVersionId from '@salesforce/apex/Prosumer_fileinput_modal_Controller.deleteDocumentFromContentVersionId';
import getFiles from '@salesforce/apex/Prosumer_fileinput_modal_Controller.getFiles';
import getProsumerAccount from '@salesforce/apex/Prosumer_AudienciaPageController.getAccountFromUser';

// ContentVersion related Imports

import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';

import CONTENT_VERSION_OBJECT from '@salesforce/schema/ContentVersion';
import TITLE_FIELD from '@salesforce/schema/ContentVersion.Title';
import PATH_ON_CLIENT_FIELD from '@salesforce/schema/ContentVersion.PathOnClient';
import VERSION_DATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import ACCOUN_FIELD from '@salesforce/schema/ContentVersion.Prosumer_Account_fileupload__c';

import RESOURCE from '@salesforce/resourceUrl/prosumerGestorArchivos';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';




const DEFAULT_FILE_TYPES = ['.pdf', '.jpg', '.jpeg', '.png', '.mp3', '.wav']

export default class Prosumer_fileinput_modal extends LightningModal {
    soundIcon = RESOURCE + '/soundIconSalesforce.png'; /* imagen del MP3/WAV */
    imageIcon = RESOURCE + '/imageIconSalesforce.png'; /* imagen del MP3/WAV */

    nube = RESOURCE + '/nube.png'; /* imagen de la nube */

    @api filestypes;
    prosumeraccountid;

    _fileList;
    get fileList() {
        if (!this._fileList) return [];
        return this._fileList;
    }

    connectedCallback() {
        console.log('debug connectedCallback');
        getProsumerAccount().then(accountid => { this.prosumeraccountid = accountid });
    
        const fileTypesArray = this.acceptedFormats.map(thisFormat => thisFormat.replace('.', ''))
    
        getFiles({ fileTypes: fileTypesArray })
            .then(fileList => {
                this._fileList = fileList.map(thisFile => ({
                    ...thisFile,
                    ContentVersion: {
                        ...thisFile.ContentVersion,
                        imageIcon: ['jpg', 'jpeg', 'png'].includes(thisFile.ContentVersion.FileType.toLowerCase()),
                        soundIcon: ['mp3', 'wav'].includes(thisFile.ContentVersion.FileType.toLowerCase())
                    }
                }));
                this._filteredFileList = this._fileList;
                console.log('file list >>> ' + JSON.stringify(this._fileList));
            })
            .catch(error => { console.log('Ocurrio un error con la cargar de files: ' + error) });
    }
    

    get acceptedFormats() {
        return this.filestypes ?? DEFAULT_FILE_TYPES;
    }

    /* DEPRECATED = Funcion del campo HTML standard files */
/*

    async handleFilesChange(event) {
        const fileInMemory = event.detail.files[0];

        const contentVersionId = await this.createContentVersion(fileInMemory);

        const contentDownloadUrl = await createLinkForContentVersionId({ contentVersionId })
            .catch(error => { console.log('Ocurrio un error al crear createLinkForContentVersionId: ', error) })

        this.close({ contentDownloadUrl, contentVersionId, fileInMemory })
    }

    async createContentVersion(file) {
        // ************************************************
        // First Creates the ContentVersion File
        // ************************************************
        
        //console.log(`antes de convertir a base64 = ${JSON.stringify(file)}`)
        const stringFile = await convertBase64(file);

        

        const fields = {};
        fields[TITLE_FIELD.fieldApiName] = file.name;
        fields[PATH_ON_CLIENT_FIELD.fieldApiName] = '/' + file.name;
        fields[ACCOUN_FIELD.fieldApiName] = this.prosumeraccountid;

        console.log('test>>>');
        console.log(stringFile);
        console.log(fields);
        console.log('test>>>');
        
        //para remover una primera parte de los data64:--->  data:audio/wav;base64,
        fields[VERSION_DATA_FIELD.fieldApiName] = stringFile.split(",")[1];

        const recordInput = { apiName: CONTENT_VERSION_OBJECT.objectApiName, fields };

        let record = await createRecord(recordInput)
            .catch(error => { console.log('Error al crear el registro de contentVersion: ', error); });
        console.log(record);
        return record.id;
    }
*/

    handleClickFile(event) {
        const clickedFileKey = event.currentTarget.dataset.filekey;
        const clickedFile = this.fileList.find(thisFile => thisFile.Id === clickedFileKey);
        this.close(
            {
                contentDownloadUrl: clickedFile.ContentDownloadUrl,
                contentVersionId: clickedFile.ContentVersionId
            }
        )
    }

    async handleEraseFile(event) {
        event.stopPropagation(); // evita que se cierre el modal de gestor de archivos

        // Animacion starts
        const fileCardElement = event.currentTarget.closest('.fileCard');
        fileCardElement.style.opacity = '0'; // Establecemos el estilo directamente en el elemento DOM
        // Animacion ends
  

       
        // ContentVersionId
        const clickedFileKey = event.currentTarget.dataset.filekey;
        const clickedFile = this.fileList.find(thisFile => thisFile.Id === clickedFileKey);
        const ContentVersionId = clickedFile.ContentVersionId;

        // Borrar (Apex)
        await deleteFileWithContentVersionId({ ContentVersionId })
        .catch(error => { console.log('Ocurrio un error al borrar el file - deleteFileWithContentVersionId: ', error) })


        // refresca el componente para ver la lista sin el dato borrado
        const fileTypesArray = this.acceptedFormats.map(thisFormat => thisFormat.replace('.', ''))

        getFiles({ fileTypes: fileTypesArray })
            .then(fileList => {
                this._fileList = fileList.map(thisFile => ({
                    ...thisFile,
                    ContentVersion: {
                        ...thisFile.ContentVersion,
                        imageIcon: ['jpg', 'jpeg', 'png'].includes(thisFile.ContentVersion.FileType.toLowerCase()),
                        soundIcon: ['mp3', 'wav'].includes(thisFile.ContentVersion.FileType.toLowerCase())
                    }
                }));
                this._filteredFileList = this._fileList;
                this.filterFileList();
                console.log('file list >>> ' + JSON.stringify(fileList));
            })
            .catch(error => { console.log('Ocurrio un error con la cargar de files: ' + error) }); 

    }



// SALESFORCE NATIVE INPUT FILE


        // List of allowed file types
        // filetype = ['.pdf', '.jpg', '.jpeg', '.png', '.mp3', '.wav'];

        // Event handler for upload finished
    async handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;       
        // Verificar si hay archivos cargados
        if (uploadedFiles && uploadedFiles.length > 0) {
            const fileInMemory = uploadedFiles[0]; // Obtener el primer archivo cargado
            const contentVersionId = fileInMemory.contentVersionId;
            // Obtener los nombres de los archivos
            const fileNames = uploadedFiles.map(file => file.name);
            try {
                const contentDownloadUrl = await createLinkForContentVersionId({ contentVersionId });
                this.close({ contentDownloadUrl, contentVersionId });
            } catch (error) {
                    console.error('Error al procesar la carga:', error);
            }
        }
    }
    
// Helper function to show a toast message

// No funciona
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

// SALESFORCE NATIVE INPUT FILE

searchKeyword = '';
_filteredFileList = []; // Inicializa el arreglo de archivos filtrados

handleSearchInputChange(event) {
    this.searchKeyword = event.target.value;
    this.filterFileList();
}

filterFileList() {
    if (!this.searchKeyword) {
        // Si el término de búsqueda está vacío, muestra la lista completa de archivos
        this._filteredFileList = this._fileList;
        return;
    }

    // Filtra la lista de archivos según el término de búsqueda
    const lowerKeyword = this.searchKeyword.toLowerCase();
    this._filteredFileList = this._fileList.filter(thisFile =>
        thisFile.ContentVersion.Title.toLowerCase().includes(lowerKeyword) ||
        thisFile.ContentVersion.FileType.toLowerCase().includes(lowerKeyword)
    );
}

}
 

function convertBase64(file) {
    return new Promise((resolve, reject) => {
        const fileReader = new FileReader();

        fileReader.onload = () => {
            resolve(fileReader.result);
        };

        fileReader.onerror = (error) => {
            reject(error);
        };

        fileReader.readAsDataURL(file);
    });
}