//
//  CustomView.h
//  MacAAA
//
//  Created by 老岳 on 16/5/14.
//  Copyright © 2016年 LYue. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LookupCusomViewDelegate;
@interface LookupCustomView : NSView
{
    BOOL canDrag;
    BOOL isEnter;
}

@property (weak, nonatomic) id<LookupCusomViewDelegate>delegate;

@end





@protocol LookupCusomViewDelegate <NSObject>

- (void)lookupCustomViewDidDragEnd:(LookupCustomView *)customView withFileUrl:(NSString *)url;

@end
