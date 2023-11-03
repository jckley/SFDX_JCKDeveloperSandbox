@isTest
public class CacheManagerTest {
    @isTest
    public static void test_cacheUsageFlow () {
        CacheManager.setSessionCache('TEST','TestValue');
        CacheManager.retrieveAndClearSessionCache('TEST');
    }
}