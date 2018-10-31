//
//  CustomView.h
//  MacAAA
//
//  Created by 老岳 on 16/5/14.
//  Copyright © 2016年 LYue. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PicCustomViewDelegate;
@interface PicCustomView : NSView
{
    BOOL canDrag;
    BOOL isEnter;
}

@property (weak, nonatomic) id<PicCustomViewDelegate>delegate;

@end





@protocol PicCustomViewDelegate <NSObject>

- (void)picCustomViewDidDragEnd:(PicCustomView *)customView withFileUrls:(NSArray *)urls;

@end
