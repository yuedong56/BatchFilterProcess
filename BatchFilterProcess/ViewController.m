//
//  ViewController.m
//  BatchFilterProcess
//
//  Created by yuedongkui on 2018/10/30.
//  Copyright © 2018年 LY. All rights reserved.
//

#import "ViewController.h"
#import "CustomView.h"

@interface ViewController ()
@property (weak) IBOutlet CustomView *addFilterView;
@property (weak) IBOutlet NSTextField *addFilterLabel;
@property (weak) IBOutlet CustomView *picsView;
@property (weak) IBOutlet CustomView *picsLabel;
@property (weak) IBOutlet NSTextField *messageLabel;

@end





@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addFilterView.wantsLayer = YES;
    self.addFilterView.layer.backgroundColor = [[NSColor greenColor] CGColor];
    
    self.picsView.wantsLayer = YES;
    self.picsView.layer.backgroundColor = [[NSColor yellowColor] CGColor];
}


@end
