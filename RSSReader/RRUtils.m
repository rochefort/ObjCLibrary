//
//  RRUtils.m
//  RSSReader
//
//  Created by rochefort on 2013/11/08.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRUtils.h"

@implementation RRUtils

+ (NSString *)replaceSlashWithUnderscore:(NSString *)str
{
    return [str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

+ (id)generateUUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *identifier = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    return identifier;
}

+ (id)transformedValue:(id)value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB"];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, tokens[multiplyFactor]];
}

@end
