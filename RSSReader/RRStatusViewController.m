//
//  RRStatusViewController.m
//  RSSReader
//
//  Created by rochefort on 2013/11/11.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRStatusViewController.h"

@interface RRStatusViewController ()
{
    DocumentEntity *documentEntity;
    RRDataManager *dataManager;
}
@end

@implementation RRStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataManager = [RRDataManager sharedManager];
    documentEntity = [dataManager find:[DocumentEntity class] byIdentifier:self.identifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // ハイライト解除
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DocumentEntity statusCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"StatusCell_%ld_%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = (UITableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    if (indexPath.row == [self.selectedStatus intValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [DocumentEntity statusDescription:@(indexPath.row)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.selectedStatus intValue]) {
        [self updateDocumentStatus:indexPath.row];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CoreData

- (void)updateDocumentStatus:(NSInteger)status
{
    // ステータス未変更であれば何もしない
    if ([documentEntity.status intValue] == status) {
        return;
    }
    
    id readDate = (status == DocumentStatusDone) ? [NSDate date] : [NSNull null];
    NSDictionary *dict = @{@"title_jp":      documentEntity.title_jp,
                           @"status":        @(status),
                           @"read_date":     readDate
                           };
    [dataManager replace:[DocumentEntity class] dict:dict];
}

@end
