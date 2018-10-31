//
//  AppDelegate.m
//  BatchFilterProcess
//
//  Created by yuedongkui on 2018/10/30.
//  Copyright © 2018年 LY. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) ViewController *mainVC;

@end




@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainVC = (ViewController *)[NSApplication sharedApplication].mainWindow.contentViewController;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }
    else {
        [self.mainVC.view.window makeKeyAndOrderFront:self];
        //        [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
        return YES;
    }
}


@end
