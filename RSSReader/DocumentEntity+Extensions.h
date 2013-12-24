//
//  DocumentEntity+Extensions.h
//  RSSReader
//
//  Created by rochefort on 2013/11/08.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "DocumentEntity.h"

@interface DocumentEntity (Extensions)

typedef NS_ENUM(NSInteger, DocumentStatus)
{
    DocumentStatusUnread = 0,
    DocumentStatusReading = 1,
    DocumentStatusDone = 2
};

typedef NS_ENUM(NSInteger, DocumentDownloadStatus)
{
    DocumentDownloadStatusNone = 0,
    DocumentDownloadStatusDone = 1,
    DocumentDownloadStatusNewer = 2,
};

+ (NSString *)keyName;
+ (NSInteger)statusCount;
+ (NSString *)statusDescription:(NSNumber *)status;

- (NSArray *)sortedDownloads;
@end
