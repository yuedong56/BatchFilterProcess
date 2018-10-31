//
//  CustomView.m
//  MacAAA
//
//  Created by 老岳 on 16/5/14.
//  Copyright © 2016年 LYue. All rights reserved.
//

#import "PicCustomView.h"

@implementation PicCustomView

- (NSArray *)extensions
{
    return @[@"jpg", @"JPG", @"JPEG", @"png", @"PNG", @"jpeg"];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    isEnter = YES;
    
    NSPasteboard *pb = [sender draggingPasteboard];
    if ([[pb types] containsObject:NSFilenamesPboardType])
    {
        NSArray *allFileUrls = [pb propertyListForType:NSFilenamesPboardType];
        NSArray *extensions = [allFileUrls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension.lowercaseString IN %@", [self extensions]]];
        if (extensions.count > 0) {
            canDrag = YES;
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    if (canDrag) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if (!isEnter) {
        return;
    }
    NSArray *allFileUrls = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSArray *array = [allFileUrls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension.lowercaseString IN %@", [self extensions]]];

    [self.delegate picCustomViewDidDragEnd:self withFileUrls:array];
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    isEnter = NO;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

@end
