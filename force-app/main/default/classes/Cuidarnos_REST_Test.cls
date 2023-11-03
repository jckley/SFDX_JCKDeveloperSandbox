@IsTest
public with sharing class Cuidarnos_REST_Test {
    @IsTest
    private static void cuponTest() {
        Cuidarnos_REST.noqueriahaceresto();
        Cuidarnos_Ficha_REST.noqueriahaceresto();
    }


}