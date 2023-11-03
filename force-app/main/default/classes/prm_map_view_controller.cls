public class prm_map_view_controller {

    public class LatLong { 
        public double Latitude 	{ get; set; }
        public double Longitude { get; set; }
        public LatLong(double Lat, double Lon) {
            Latitude = Lat;
            Longitude = Lon;
        } 
    }

    @RemoteAction
    public static List<LatLong> get_coordinates() {
        List<LatLong> arrLocations = new List<LatLong>(); 
        List<Contact> lstContacts = new List<Contact>();

        /*
        lstContacts = [SELECT Id, geo_location__latitude__s, geo_location__longitude__s 
                        FROM Contact
                        WHERE geo_location__latitude__s < 0
                        LIMIT 200];
       
        for (Integer i = 0 ; i < lstContacts.size() ; i++) {
            Contact cont = lstContacts.get(i);
            arrLocations.add(new LatLong((double)cont.geo_location__Latitude__s, (double)cont.geo_location__Longitude__s));
        }
        */

        return arrLocations;
    }


	//@RemoteAction
    //public static List<List<double>> get_coordinates3() {
    //    List<List<double>> arrLocations = new List<List<double>>(); 
    //    List<Contact> lstContacts = new List<Contact>();

        //lstContacts = [SELECT Id, geo_location__latitude__s, geo_location__longitude__s 
        //                FROM Contact
        //                WHERE geo_location__latitude__s < 0
        //                LIMIT 2000];
        
        //for (Integer i = 0 ; i < lstContacts.size() ; i++) {
        //    Contact coord = lstContacts.get(i);
        //    arrLocations.add(new List<double>{(double)coord.geo_location__Latitude__s, (double)coord.geo_location__Longitude__s});
        //}

        //return arrLocations;
    //}

}