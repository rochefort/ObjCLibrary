//
//  RRDataManager.m
//  RSSReader
//
//  Created by rochefort on 2013/10/25.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRDataManager.h"
#import "DocumentEntity.h"

@implementation RRDataManager

NSString *const kDBName = @"documents.db";

+ (id)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [RRDataManager new];
    });
    return sharedInstance;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error = nil;
    NSPersistentStore *persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:[self storeURL]
                                                                         options:nil
                                                                           error:&error];
    if (!persistentStore && error) {
        NSLog(@"Failed to create add persitent store, %@", [error localizedDescription]);
    }
    
    _managedObjectContext = [NSManagedObjectContext new];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - property

- (NSArray *)getDocumentList
{
    self.documentList = [self find:[DocumentEntity class]];
    return _documentList;
}

#pragma mark - CRUD

- (NSArray *)find:(Class)entity
{
    NSFetchRequest *request = [self fetchRequestForEntity:[entity class] withSortDescriptors:nil];
    return [self resultsWithRequest:(NSFetchRequest *)request];
}

- (id)find:(Class)entity byIdentifier:(NSString *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    return [self findFirst:entity by:predicate];
}

- (NSArray *)find:(Class)entity by:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self fetchRequestForEntity:[entity class] withSortDescriptors:nil];
    [request setPredicate:predicate];
    return [self resultsWithRequest:request];;
}

- (NSArray *)find:(Class)entity by:(NSPredicate *)predicate order:(NSSortDescriptor *)sortDiscriptor
{
    NSFetchRequest *request = [self fetchRequestForEntity:[entity class] withSortDescriptors:sortDiscriptor];
    [request setPredicate:predicate];
    return [self resultsWithRequest:request];;
}

- (id)findFirst:(Class)entity by:(NSPredicate *)predicate
{
    NSArray *results = [self find:entity by:predicate];
    if ([results count] > 0) {
        return results[0];
    }
    return nil;
}

- (void)replace:(Class)entity dict:(NSDictionary *)dict
{
    NSString *keyName = [entity keyName];
    NSString *titleJp = dict[keyName];
    assert(titleJp != nil);
    
    NSString *condition = [NSString stringWithFormat:@"%@ == %%@", keyName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:condition, titleJp];
    id record = [self findFirst:entity by:predicate];
    
    if (!record) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(entity)
                                               inManagedObjectContext:self.managedObjectContext];
    }
    [self updateAttributes:record dict:dict];
    [self save];
}

- (void)destroy:(Class)entity byIdentifier:(NSString *)identifier
{
    id record = [self find:[entity class] byIdentifier:identifier];
    if (!record) {
        return;
    }
    [self updateAttributes:record dict:@{@"deleted": @(1)}];
    [self save];
}

- (void)updateAttributes:(id)managedObject dict:(NSDictionary *)dict
{
    BOOL isChange = NO;
    NSArray * keys = [dict allKeys];
    for (NSString *key in keys) {
        id befVal = [managedObject valueForKey:key];
        id aftVal = dict[key];
        if ([befVal isEqual:aftVal]) {
            continue;
        }
        isChange = YES;
        
        // Entity毎の処理
        if ([managedObject isKindOfClass:[DocumentEntity class]]) {
            if ([key isEqualToString:@"revision_date_jp"]) {
                DocumentEntity *document = (DocumentEntity *)managedObject;
                if (document.revision_date_jp != dict[key]) {
                    [managedObject setValue:@(DocumentDownloadStatusNewer) forKey:@"download_status"];
                } else {
                    [managedObject setValue:@(DocumentDownloadStatusNone) forKey:@"download_status"];
                }
            }
        }
        // 更新情報セット
        if (dict[key] == [NSNull null]) {
            [managedObject setValue:nil forKey:key];
        } else {
            [managedObject setValue:dict[key] forKey:key];
        }
    }
    if (isChange) {
        LOG(@"-- updating, %@", managedObject)
        [managedObject setValue:[NSDate date] forKey:@"updated_at"];
    } else {
        LOG(@"-- no changing")
    }
}

- (void)replaceDocument:(NSDictionary *)documentDict downloadDict:(NSDictionary *)downloadDict
{
    Class entity = [DocumentEntity class];
    NSString *keyName = [DocumentEntity keyName];
    NSString *titleJp = documentDict[keyName];

    NSString *condition = [NSString stringWithFormat:@"%@ == %%@", keyName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:condition, titleJp];

    DocumentEntity *document = [self findFirst:entity by:predicate];
    if (!document) {
        document = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(entity)
                                               inManagedObjectContext:self.managedObjectContext];
    }
    DownloadEntity *download =[NSEntityDescription insertNewObjectForEntityForName:@"DownloadEntity"
                                                            inManagedObjectContext:self.managedObjectContext];
    [self updateAttributes:document dict:documentDict];
    [self updateAttributes:download dict:downloadDict];
    [document addDownloadsObject:download];
    [self save];
}

- (void)destroy
{
    LOG_METHOD
}

- (NSFetchRequest *)fetchRequestForEntity:(Class)class withSortDescriptors:(NSSortDescriptor *)sortDescriptor
{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class)
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    if (sortDescriptor) {
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    return  request;
}

#pragma mark - operate DocumentEntity

- (void)deleteOldDocuments:(DocumentEntity *)documentEntity
{
    for (DownloadEntity *download in documentEntity.sortedDownloads) {
        [self deleteDocument:download];
    }
}

- (void)deleteDocument:(DownloadEntity *)download
{
    RRDataManager *manager = [RRDataManager sharedManager];
    [manager destroy:[DownloadEntity class] byIdentifier:download.identifier];
}

#pragma mark - private

- (void)save
{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"save: failed, %@", [error localizedDescription]);
    }
}

/*!
 * DBファイルの場所を返す
 */
- (NSURL *)storeURL
{
    NSURL *url = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        NSString *path = [paths[0] stringByAppendingPathComponent:kDBName];
        url = [NSURL fileURLWithPath:path];
    }
    return url;
}

/*!
 * 取得要求を実行する
 */
- (NSArray *)resultsWithRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"executeFetchRequest: failed, %@", [error localizedDescription]);
    }
    return results;
}

@end
