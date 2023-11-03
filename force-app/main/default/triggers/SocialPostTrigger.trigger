trigger SocialPostTrigger on SocialPost (after insert) {
    System.debug('SocialPostTrigger [' + Trigger.new + '] ->');
    
	SocialPostController.sendNotifications(Trigger.New);
    
    System.debug('SocialPostTrigger [] <-');
}