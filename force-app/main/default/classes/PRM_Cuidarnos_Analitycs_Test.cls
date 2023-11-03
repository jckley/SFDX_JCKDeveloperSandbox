@IsTest
private class PRM_Cuidarnos_Analitycs_Test {
    @IsTest
    private static void iframeTest() {
        PRM_Cuidarnos_Analitycs.retrieveDashboardId('Territorial');
        PRM_Cuidarnos_Analitycs.retrieveDashboardId('Sintomas');
        PRM_Cuidarnos_Analitycs.retrieveDashboardId('Saniario');
    }
}