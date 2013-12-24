//
//  DocumentEntity.h
//  RSSReader
//
//  Created by rochefort on 2013/11/19.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DownloadEntity;

@interface DocumentEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * download_status;
@property (nonatomic, retain) NSString * framework;
@property (nonatomic, retain) NSString * link_en;
@property (nonatomic, retain) NSString * link_jp;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSDate * read_date;
@property (nonatomic, retain) NSString * revision_date_en;
@property (nonatomic, retain) NSString * revision_date_jp;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * sub_topic;
@property (nonatomic, retain) NSString * title_en;
@property (nonatomic, retain) NSString * title_jp;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSSet *downloads;
@end

@interface DocumentEntity (CoreDataGeneratedAccessors)

- (void)addDownloadsObject:(DownloadEntity *)value;
- (void)removeDownloadsObject:(DownloadEntity *)value;
- (void)addDownloads:(NSSet *)values;
- (void)removeDownloads:(NSSet *)values;

@end
