public class CSVStream {
    public static Boolean isTest;
    public static String strEmailAddr;
    public static String strOut;
    public static Boolean restRequested;
    public String strEmail{get;set;}
    public String strRptname{get;set;}
    
    public CSVStream () {
        strOut = '';        
        }
 
   public String getCSVStream() {
        restRequested = System.isFuture() || System.isScheduled();
        executeRpt();
        return strOut;
        }
  
    public void executeRpt() {
        String requestURL;
        requestURL = '/' + strRptname + '?csv=1&exp=1';
        if(!Test.isRunningTest())
        	strOut = new PageReference(requestURL).getContent().toString();
        
        System.debug('CALLING executeRpt:  output= ' + strOut );
    }
 
}