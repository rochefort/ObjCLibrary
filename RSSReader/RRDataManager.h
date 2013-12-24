//
//  RRDataManager.h
//  RSSReader
//
//  Created by rochefort on 2013/10/25.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentEntity.h"

/// データ管理クラス
@interface RRDataManager : NSObject

@property (nonatomic, getter = getDocumentList) NSArray *documentList;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

/// シングルトン生成
+ (id)sharedManager;

// 汎用CRUD
/// 検索
- (NSArray *)find:(Class)entity;
/// key検索
- (id)find:(Class)entity byIdentifier:(NSString *)identifier;
/// 条件検索
- (NSArray *)find:(Class)entity by:(NSPredicate *)predicate;
/// 条件検索ソート付
- (NSArray *)find:(Class)entity by:(NSPredicate *)predicate order:(NSSortDescriptor *)sortDiscriptor;
/// 1件目の条件検索
- (id)findFirst:(Class)entity by:(NSPredicate *)predicate;
/// 登録/更新
- (void)replace:(Class)entity dict:(NSDictionary *)dict;
/// 更新
- (void)updateAttributes:(id)managedObject dict:(NSDictionary *)dict;
/// 論理削除
- (void)destroy:(Class)entity byIdentifier:(NSString *)identifier;

// Entity別CRUD
- (void)deleteOldDocuments:(DocumentEntity *)documentEntity;
- (void)replaceDocument:(NSDictionary *)documentDict downloadDict:(NSDictionary *)downloadDict;


@end
