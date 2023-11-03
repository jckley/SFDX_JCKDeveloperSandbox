import { LightningElement, api } from 'lwc';

import default_layout from './default_layout.html';
import brasil from './brasil.html';
import evolucion_layout from './evolucion_layout.html';

import PROSUMER from '@salesforce/resourceUrl/prosumerCitizen'

const conjunto_de_parametros = {
    default: {
        ordinales_vacunas: {
            0: 'Primera dosis',
            1: 'Segunda dosis',
            2: 'Tercera dosis'
        },
        choosed_layout: default_layout,
        booleanValues:{
            true:'SI',
            false:'NO'
        }
    },
    brasil: {
        ordinales_vacunas: {
            0: 'PRIMERIRA DOSE',
            1: 'SEGUNDA DOSE',
            2: 'TERCEIRA DOSE'
        },
        choosed_layout: brasil,
        booleanValues:{
            true:'SIM',
            false:'NÃO'
        }
    },
    evolucion: {
        ordinales_vacunas: {
            0: 'Primera dosis',
            1: 'Segunda dosis',
            2: 'Tercera dosis'
        },
        choosed_layout: evolucion_layout,
        booleanValues:{
            true:'SI',
            false:'NO'
        }
    }
};

export default class prosumer_section_salud extends LightningElement {
    salud = PROSUMER + "/salud.png";

    _datos;
    _iconsrc;
    @api template_seleccionado;

    get parametros_seleccionados () {
        if (!this.template_seleccionado) {
            return conjunto_de_parametros.default
        }

        return conjunto_de_parametros[this.template_seleccionado];
    }


    render() {
        return this.parametros_seleccionados.choosed_layout;
    }

    @api
    get datos(){
        return this._datos;
    }
    set datos(value){ 
        console.log('Parametros via api: ', JSON.stringify(value))
        let ordinalesToUse = this.parametros_seleccionados.ordinales_vacunas;

        let vacunas = value.vacunas?.map(thisVacuna =>{
            const nombre = thisVacuna.nombre;
            const fecha = thisVacuna.fecha ? thisVacuna.fecha : '-';
            const dosis = ordinalesToUse.hasOwnProperty(thisVacuna.dosis) ? ordinalesToUse[thisVacuna.dosis] : thisVacuna.dosis + 1;
            return {nombre, fecha, dosis};
        });

        console.log("comorbilidades to process = ", value.comorbilidades);
        let comorbilidadesTemp = this.processComorbilidades (value.comorbilidades);
        
        console.log("process comorbilidades = ", comorbilidadesTemp);

        let tempObject = {
            ...value,
            comorbilidades : comorbilidadesTemp,
            tiene_comorbilidades: comorbilidadesTemp ? true : false,
            tiene_obraSocial: value.obraSocial ? true : false,
            tuvoCovid: value.tuvoCovid ? this.parametros_seleccionados.booleanValues.true : this.parametros_seleccionados.booleanValues.false,
            vacunas: vacunas,
            mostrarVacunas: vacunas ? true : false,
        };

        console.log('Parametros procesados: ', JSON.stringify(tempObject))
 
        this._datos = tempObject;

        this.icon = this.iconsrc;
    }

    comorbilidadesArray = [];

    processComorbilidades (comorbilidades){
        //remover valores que deberian ser null y rearmar string
        const COMORBILIDADES_A_FILTRAR = ['None','/','A']; 
        
        if(!comorbilidades || comorbilidades.lenght == 0){
            return;
        }

        let arrayTemp = comorbilidades.split(';');
        let arrayTempFiltered = arrayTemp.filter(
            thisElement => !COMORBILIDADES_A_FILTRAR.includes(thisElement)
        );

        if (!arrayTempFiltered || arrayTempFiltered.lenght == 0){
            return;
        }

        this.comorbilidadesArray = arrayTempFiltered;

        let valoresEnEspanol = [];

        
        for(let i = 0; i < this.comorbilidadesArray.length; i++) {
         switch(this.comorbilidadesArray[i]) {
                case 'HEART_FAILURE':
                    valoresEnEspanol.push('Insuficiencia Cardiaca');
                    break;
                case 'SMOKER':
                    valoresEnEspanol.push('Fumador');
                    break;
                case 'PREGNANT':
                    valoresEnEspanol.push('Embarazada');
                    break;
                case 'KIDNEY_FAILURE':
                    valoresEnEspanol.push('Fallo Renal');
                    break;
                case 'NEURO_DISORDER':
                    valoresEnEspanol.push('Trastorno Neurológico');
                    break;
                case 'UNDERWEIGHT':
                    valoresEnEspanol.push('Bajo Peso');
                    break;
                case 'ASTHMA':
                    valoresEnEspanol.push('Asma');
                    break;
                case 'COPD':
                    valoresEnEspanol.push('Enfermedad Pulmonar Obstructiva Crónica');
                    break;
                case 'DIABETES':
                    valoresEnEspanol.push('Diabetes');
                    break;
                case 'HBP':
                    valoresEnEspanol.push('Hipertensión');
                    break;
                case 'PREMATURE':
                    valoresEnEspanol.push('Prematuro');
                    break;
                case 'OBESITY':
                    valoresEnEspanol.push('Obesidad');
                    break;
                case 'ONCOLOGIC':
                    valoresEnEspanol.push('Oncológico');
                    break;
                case 'TB':
                    valoresEnEspanol.push('Tuberculosis');
                    break;
                case 'AKI':
                    valoresEnEspanol.push('Lesión Renal Aguda');
                    break;
                case 'CKD':
                    valoresEnEspanol.push('Enfermedad Renal Crónica');
                    break;
                case 'FORMER_SMOKER':
                    valoresEnEspanol.push('Exfumador');
                    break;
                case 'CHRONIC_LIVER_DISEASE':
                    valoresEnEspanol.push('Enfermedad Hepática Crónica');
                    break;
                case 'IMMUNE_CONGENITAL':
                    valoresEnEspanol.push('Inmunodeficiencia congénita');
                    break;
                case 'BRONCHITIS':
                    valoresEnEspanol.push('Bronquitis');
                    break;
                case 'CAP':
                    valoresEnEspanol.push('Neumonía');
                    break;
                case 'Discapacidad':
                    break;
                    default:
                    //labelForFilter = '-';
                    break;
                }
            }

          this.comorbilidadesArray = valoresEnEspanol;

        return arrayTempFiltered.join('; ');

    }

    @api
    get iconsrc() {
        return this._iconsrc;
    }
    set iconsrc(value) {
        this._iconsrc = value;
        console.log('iconsrc: ', this.iconsrc);
    }

}