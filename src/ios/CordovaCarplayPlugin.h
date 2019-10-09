// copyright 2019 by Mike Nelson, beweb
// open source by MIT license terms

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CordovaCarplayPlugin : CDVPlugin
+ (CordovaCarplayPlugin *) carplayPlugin;

- (void)registerHandler:(CDVInvokedUrlCommand*)command;
- (void)setMediaItems:(CDVInvokedUrlCommand*)command;
- (void)setSingleMediaItem:(CDVInvokedUrlCommand*)command;
- (void)finishedPlaying:(CDVInvokedUrlCommand*)command;
    
- (void)handlePlayback:(int)trackIndex completionHandler:(void (^)(NSError *))completionHandler;
- (int)requestItemCount;
- (MPContentItem*)requestItemMetaDataByIndex:(int)trackIndex;

@end
