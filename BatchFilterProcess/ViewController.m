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
    NSImageView *tempImageView;
}
@property (strong) LookupCustomView *lookupView;
@property (weak) IBOutlet NSTextField *addFilterLabel;

@property (strong) PicCustomView *picsView;
@property (weak) IBOutlet NSTextField *picsLabel;

@property (weak) IBOutlet NSTextField *messageLabel;
@property (weak) IBOutlet NSProgressIndicator *hud;

@property (strong) GPUImageLookupFilter *lookupFilter;
@property (strong) GPUImagePicture *lookupPic;

@property (weak) IBOutlet NSTextField *powerLabel;
@end





@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tempImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    [self.view addSubview:tempImageView];

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
        alert.messageText = @"没找到滤镜基准图（lookup）";
        alert.informativeText = @"请先拖入滤镜基准图（lookup）";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return;
    }
    
    self.hud.hidden = NO;
    [self.hud startAnimation:nil];
    self.messageLabel.stringValue = @"准备处理...";
    
    self.lookupFilter.intensity = self.powerLabel.floatValue/100.0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->picUrls enumerateObjectsUsingBlock:^(NSString *picUrl, NSUInteger idx, BOOL *stop) {
            [self.lookupPic removeAllTargets];
            [self.lookupPic addTarget:self.lookupFilter atTextureLocation:1];
            [self.lookupPic processImage];
            
            GPUImagePicture *targetPicture = [[GPUImagePicture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:picUrl]];
            [targetPicture addTarget:self.lookupFilter];
            
            [self.lookupFilter useNextFrameForImageCapture];
            [targetPicture processImage];
            NSImage *resultImage = [self.lookupFilter imageFromCurrentFramebuffer];
            
            //tempImageView.image = resultImage;
            //图片写入文件
            NSData *imageData = [resultImage TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            
            NSNumber *quality = @(1);
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject:quality forKey:NSImageCompressionFactor];
            imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
            
            NSString *dirPath = [NSString stringWithFormat:@"%@/处理结果", [picUrl stringByDeletingLastPathComponent]];
            if (idx == 0 && (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])) {
                //在目录下创建个文件夹
                BOOL isCreatSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
                NSLog(@"创建文件夹是否成功 = %d", isCreatSuccess);
            }
            //写文件
            BOOL isSuccess = [imageData writeToFile:[NSString stringWithFormat:@"%@/%@", dirPath, picUrl.lastPathComponent]
                                         atomically:YES];
            NSLog(@"isSuccess ---- %d", isSuccess);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *errorImageNames = [NSMutableArray arrayWithCapacity:0];
                if (isSuccess) {
                    self.messageLabel.stringValue = [NSString stringWithFormat:@"第%ld张图片处理结束 (%@)", idx+1, picUrl.lastPathComponent];
                } else {
                    self.messageLabel.stringValue = [NSString stringWithFormat:@"⚠️ 处理失败 (%@)", picUrl.lastPathComponent];
                    [errorImageNames addObject:picUrl.lastPathComponent];
                }
                if (idx == self->picUrls.count-1)
                {
                    [self.hud stopAnimation:nil];
                    self.hud.hidden = YES;
                    
                    if (errorImageNames.count == 0) {
                        self.messageLabel.stringValue = @"✅ 处理完毕，未发现异常";
                    } else {
                        NSMutableString *errorimg = [NSMutableString string];
                        for (NSString *imageName in errorImageNames) {
                            [errorimg appendString:imageName];
                        }
                        self.messageLabel.stringValue = [NSString stringWithFormat:@"处理完毕，发现 %ld 处异常, 分别是: %@", errorImageNames.count, errorimg];
                    }
                    
                    //打开处理结果目录
                    [self runCmdPath:@"/usr/bin/open" arguments:@[dirPath]];
                }
            });
        }];
    });
}

#pragma mark - CusomViewDelegate
- (void)lookupCustomViewDidDragEnd:(LookupCustomView *)customView withFileUrl:(NSString *)url;
{
    self.addFilterLabel.stringValue = url;
    
    self.lookupFilter = [[GPUImageLookupFilter alloc] init];
    self.lookupPic = [[GPUImagePicture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:url] ];
}

#pragma mark - PicCustomViewDelegate
- (void)picCustomViewDidDragEnd:(PicCustomView *)customView withFileUrls:(NSArray *)urls
{
    self.picsLabel.stringValue = [NSString stringWithFormat:@"已添加 %ld 张图片", urls.count];
    picUrls = urls;
}

#pragma mark -
- (NSString *)runCmdPath:(NSString *)path arguments:(NSArray *)args
{
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:path];
    [task setArguments:args];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData:data
                                   encoding:NSUTF8StringEncoding];
    return string;
}

@end
