// copyright 2019 by Mike Nelson, beweb
// open source by MIT license terms

#import "AppDelegate+CordovaCarplayPlugin.h"
#import "CordovaCarplayPlugin.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>

MPPlayableContentManager* playableContentManager;

@interface AppDelegate () <MPPlayableContentDelegate, MPPlayableContentDataSource>
- (NSInteger)numberOfChildItemsAtIndexPath:(NSIndexPath *)indexPath;
@end



#define kApplicationInBackgroundKey @"applicationInBackground"
#define kDelegateKey @"delegate"

@implementation AppDelegate (CordovaCarplayPlugin)

- (void)setDelegate:(id)delegate {
    objc_setAssociatedObject(self, kDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)delegate {
    return objc_getAssociatedObject(self, kDelegateKey);
}

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:swizzledDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, swizzled);
}

- (void)setApplicationInBackground:(NSNumber *)applicationInBackground {
    objc_setAssociatedObject(self, kApplicationInBackgroundKey, applicationInBackground, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)applicationInBackground {
    return objc_getAssociatedObject(self, kApplicationInBackgroundKey);
}

- (BOOL)application:(UIApplication *)application swizzledDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self application:application swizzledDidFinishLaunchingWithOptions:launchOptions];
    
    @try{

        MPPlayableContentManager *contentManager = [MPPlayableContentManager sharedContentManager];
        contentManager.dataSource = self;
        contentManager.delegate = self;
      
        self.applicationInBackground = @(YES);
        
    }@catch (NSException *exception) {
    }

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.applicationInBackground = @(NO);
    NSLog(@"FCM direct channel = true");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.applicationInBackground = @(YES);
    NSLog(@"FCM direct channel = false");
}


//Tells the app that a remote notification arrived that indicates there is data to be fetched.
// Called when a message arrives in the foreground and remote notifications permission has been granted
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    @try{
        NSDictionary *mutableUserInfo = [userInfo mutableCopy];
        NSDictionary* aps = [mutableUserInfo objectForKey:@"aps"];
        if([aps objectForKey:@"alert"] != nil){
            [mutableUserInfo setValue:@"notification" forKey:@"messageType"];
            NSString* tap;
            if([self.applicationInBackground isEqual:[NSNumber numberWithBool:YES]]){
                tap = @"background";
            }
            [mutableUserInfo setValue:tap forKey:@"tap"];
        }else{
            [mutableUserInfo setValue:@"data" forKey:@"messageType"];
        }

        NSLog(@"didReceiveRemoteNotification: %@", mutableUserInfo);
        
        completionHandler(UIBackgroundFetchResultNewData);
     //   [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
    }@catch (NSException *exception) {
   //     [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}


- (NSInteger)numberOfChildItemsAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"numberOfChildItemsAtIndexPath");
    int count = [CordovaCarplayPlugin.carplayPlugin requestItemCount];
    return count;
}

- (nullable MPContentItem *)contentItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
   NSLog(@"contentItemAtIndexPath");
    
   // MPContentItem* item = [[MPContentItem alloc] initWithIdentifier:@"Email 1"];
   // item.title = @"Subject: my email test";
   // item.subtitle = @"From: Mike Nelson";
   // item.playable = YES;
    
    int index = (int)[indexPath indexAtPosition:0];
    MPContentItem* item = [CordovaCarplayPlugin.carplayPlugin requestItemMetaDataByIndex:index];
    
    //streamingContent
    //container
    return item;
}

- (void)playableContentManager:(MPPlayableContentManager *)contentManager
initiatePlaybackOfContentItemAtIndexPath:(NSIndexPath *)indexPath
             completionHandler:(void (^)(NSError *))completionHandler{
    NSLog(@"contentItemAtIndexPath");
    
    int index = (int)[indexPath indexAtPosition:0];
    [CordovaCarplayPlugin.carplayPlugin handlePlayback:index completionHandler:completionHandler];
    
    //completionHandler(nil);
}

- (void)beginLoadingChildItemsAtIndexPath:(NSIndexPath *)indexPath 
                        completionHandler:(void (^)(NSError *))completionHandler{

    // call out to js to load the stuff, then call the completion handler
    
    completionHandler(nil);
}

@end
