//
//  RRUtils.h
//  RSSReader
//
//  Created by rochefort on 2013/11/08.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRUtils : NSObject

+ (NSString *)replaceSlashWithUnderscore:(NSString *)str;
+ (id)generateUUID;
+ (id)transformedValue:(id)value;
@end
