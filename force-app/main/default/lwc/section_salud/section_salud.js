import { LightningElement, api } from 'lwc';

import default_layout from './default_layout.html';
import brasil from './brasil.html';
import evolucion_layout from './evolucion_layout.html';

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

export default class Section_salud extends LightningElement {

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