//
//  RRDocumentCell.m
//  RSSReader
//
//  Created by rochefort on 2013/10/26.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRDocumentCell.h"

@implementation RRDocumentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
