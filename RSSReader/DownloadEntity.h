//
//  DownloadEntity.h
//  RSSReader
//
//  Created by rochefort on 2013/11/26.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DocumentEntity;

@interface DownloadEntity : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSDate * download_date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * pdf_name;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) DocumentEntity *document;

@end
