//
//  ViewController.m
//  BatchFilterProcess
//
//  Created by yuedongkui on 2018/10/30.
//  Copyright © 2018年 LY. All rights reserved.
//

#import "ViewController.h"
#import "LookupCustomView.h"
#import "PicCustomView.h"
#import <GPUImage/GPUImage.h>

#define kScreenHeight self.view.bounds.size.height
#define kScreenWidth  self.view.bounds.size.width


@interface ViewController () <LookupCusomViewDelegate, PicCustomViewDelegate>
{
    NSArray *picUrls;
    NSImageView *imageview;
}
@property (strong) LookupCustomView *lookupView;
@property (weak) IBOutlet NSTextField *addFilterLabel;

@property (strong) PicCustomView *picsView;
@property (weak) IBOutlet NSTextField *picsLabel;

@property (weak) IBOutlet NSTextField *messageLabel;

@property (strong) GPUImageLookupFilter *lookupFilter;
@property (strong) GPUImagePicture *lookupPic;

@end





@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    
    self.lookupView = [[LookupCustomView alloc] initWithFrame:CGRectZero];
    self.lookupView.wantsLayer = YES;
    self.lookupView.layer.backgroundColor = [[NSColor greenColor] CGColor];
    self.lookupView.delegate = self;
    [self.view addSubview:self.lookupView
               positioned:NSWindowBelow
               relativeTo:self.addFilterLabel] ;
    
    self.picsView = [[PicCustomView alloc] initWithFrame:NSZeroRect];
    self.picsView.wantsLayer = YES;
    self.picsView.layer.backgroundColor = [[NSColor yellowColor] CGColor];
    self.picsView.delegate = self;
    [self.view addSubview:self.picsView
               positioned:NSWindowBelow
               relativeTo:self.picsLabel];
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    CGFloat viewHeight = 80;
    self.lookupView.frame = NSMakeRect(5, kScreenHeight-viewHeight-5, kScreenWidth-10, viewHeight);
    self.picsView.frame = NSMakeRect(5, kScreenHeight-viewHeight*2-10, kScreenWidth-10, viewHeight);
}

#pragma mark - Buttons Action
- (IBAction)startButtonAction:(id)sender
{
    if (![self.addFilterLabel.stringValue hasPrefix:@"/User"]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"没找到滤镜基准图";
        alert.informativeText = @"请先拖入滤镜基准图";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return;
    }
    
    GPUImagePicture *targetPicture = [[GPUImagePicture alloc] initWithImage:[NSImage imageNamed:@"123.jpg"]];
    [targetPicture addTarget:self.lookupFilter];
   
    [self.lookupFilter useNextFrameForImageCapture];
    [targetPicture processImage];
    NSImage *resultImage = [self.lookupFilter imageFromCurrentFramebuffer];
    
    //图片写入文件
    NSData *imageData = [resultImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];

    NSNumber *quality = @(1);
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:quality forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];

    //写文件
    BOOL isSuccess = [imageData writeToFile:@"/Users/yuedongkui/Desktop/123.png" atomically:YES];
    NSLog(@"isSuccess ---- %d", isSuccess);
}

#pragma mark - CusomViewDelegate
- (void)lookupCustomViewDidDragEnd:(LookupCustomView *)customView withFileUrl:(NSString *)url;
{
    self.addFilterLabel.stringValue = url;
    
    self.lookupFilter = [[GPUImageLookupFilter alloc] init];
    self.lookupPic = [[GPUImagePicture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:url] ];
    [self.lookupPic addTarget:self.lookupFilter atTextureLocation:1];
    [self.lookupPic processImage];
}

#pragma mark - PicCustomViewDelegate
- (void)picCustomViewDidDragEnd:(PicCustomView *)customView withFileUrls:(NSArray *)urls
{
    self.picsLabel.stringValue = [NSString stringWithFormat:@"已添加 %ld 张图片", urls.count];
}


@end
