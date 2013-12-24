//
//  RRDocumentCell.h
//  RSSReader
//
//  Created by rochefort on 2013/10/26.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRDocumentCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *titleJpLabel;
@property (nonatomic) IBOutlet UILabel *topicLabel;
@property (nonatomic) IBOutlet UILabel *revisionDateJaLabel;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) NSString *identifier;

@end
