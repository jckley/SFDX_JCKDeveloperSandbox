public with sharing class CacheManager {
    
    @AuraEnabled
    public static string setSessionCache(String key, String value){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put(key, value);
        return (String)sessionPart.get(key);
    }

    @AuraEnabled
    public static string retrieveAndClearSessionCache(String key){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        if (!sessionPart.contains(key)) {
            return null;
        }

        String value = (String)sessionPart.get(key);
        sessionPart.remove(key);
        return value;
    }
}