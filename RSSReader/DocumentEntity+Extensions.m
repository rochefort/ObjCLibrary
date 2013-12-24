//
//  DocumentEntity+Extensions.m
//  RSSReader
//
//  Created by rochefort on 2013/11/08.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "DocumentEntity+Extensions.h"

static NSString *const kStatusUnread  = @"これから読む";
static NSString *const kStatusReading = @"いま読んでいる";
static NSString *const kStatusDone    = @"読み終わった";

@implementation DocumentEntity (Extensions)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.identifier = [RRUtils generateUUID];
    self.created_at = [NSDate date];
}

+ (NSString *)keyName
{
    return @"title_jp";
}

+ (NSInteger)statusCount
{
    return 3;
}

+ (NSString *)statusDescription:(NSNumber *)status
{
    switch ((DocumentStatus)[status intValue]) {
        case DocumentStatusReading:
            return kStatusReading;
        case DocumentStatusDone:
            return kStatusDone;
        default:
            return kStatusUnread;
    }
}

- (NSArray *)sortedDownloads {
    
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
    NSArray *sortedList = [self.downloads sortedArrayUsingDescriptors:sortDescriptors];

    NSMutableArray *activeList = [NSMutableArray array];
    for (DownloadEntity *entity in sortedList) {
        if ([entity.deleted intValue] == 0) {
            [activeList addObject:entity];
        }
    }
    return activeList;
}

@end
