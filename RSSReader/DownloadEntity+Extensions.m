//
//  DownloadEntity+Extensions.m
//  RSSReader
//
//  Created by rochefort on 2013/11/19.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "DownloadEntity+Extensions.h"

@implementation DownloadEntity (Extensions)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.identifier = [RRUtils generateUUID];
    self.created_at = [NSDate date];
}

@end
