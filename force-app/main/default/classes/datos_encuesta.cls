public class datos_encuesta {
    public Id id { get; set;}	
    public integer nro_pregunta {get ; set;}
    public string titulo {get; set;}
    public opciones [] lista_opciones {get; set;}
    public integer suma_respuestas {get; set;}
    public integer suma_respuestas_cuitificadas { get; set; }
    
    public class opciones {
        public String opcionid 	{ get; set;}
        public integer nro_opcion {get; set;}
        public string pregunta {get; set;}
        public integer respuestas {get; set;}
        public integer respuestas_cuitificadas {get; set;}
        public integer porcentaje {get; set;}
        public integer porcentaje_cuitificado {get; set;}        
    }
}