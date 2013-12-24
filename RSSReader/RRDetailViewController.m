//
//  RRDetailViewController.m
//  RSSReader
//
//  Created by rochefort on 2013/10/29.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRDetailViewController.h"
#import "AMRatingControl.h"

#import "RRAppDelegate.h"
#import "RRPDFViewController.h"
#import "RRStatusViewController.h"

@interface RRDetailViewController () {
    RRDataManager *dataManager;
    RRPlaceholderTextView *noteTextView;
    DocumentEntity *documentEntity;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UILabel *titleJpLabel;
@property (nonatomic) IBOutlet UILabel *titleEnLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *downloadIconLabel;

@property (nonatomic) NSArray *cellTitles;
@property (nonatomic) NSArray *cellValues;

@property (strong, nonatomic) IBOutlet UIView *tapAreaView;
- (IBAction)tapGesture:(UIGestureRecognizer *)recognizer;
- (IBAction)longPressGesture:(id)sender;
- (IBAction)swipeGesture:(id)sender;

@end

static const CGFloat cellPaddingX = 20;
static const CGFloat cellY = 6;
static const CGFloat cellHight = 20;
static const CGFloat headerHeight = 25;
static const CGFloat noteHeight = 130;

@implementation RRDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setup
{
    LOG_METHOD
    dataManager = [RRDataManager sharedManager];
    DocumentEntity *d = [dataManager find:[DocumentEntity class] byIdentifier:self.identifier];
    documentEntity = d;
//    LOG(@"%@", d)
    self.titleJpLabel.text = d.title_jp;
    self.titleEnLabel.text = d.title_en;
    if ([d.sortedDownloads count] > 0) {
        DownloadEntity *dl = d.sortedDownloads[0];
        self.sizeLabel.text = [RRUtils transformedValue:dl.size];
        FAKIcon *fileIcon = [FAKFontAwesome fileOIconWithSize:12];
        self.downloadIconLabel.attributedText = [fileIcon attributedString];

    } else {
        self.sizeLabel.text = @"";
        self.downloadIconLabel.text = @"";
    }
    
    self.cellTitles = @[@"Topic", @"Sub Topic", @"Framework", @"Revision Date (JP)", @"Revision Date (EN)"];
    self.cellValues = @[d.topic, d.sub_topic, d.framework, d.revision_date_jp, d.revision_date_en];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setup];
    [self.tableView reloadData];

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // ハイライト解除
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.tapAreaView.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [noteTextView resignFirstResponder];
}

#pragma mark - UITableView

#define ONE_SECTION 0

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 5;
        case 1:
            return 2;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:
            return 26;
        case 2:
            return noteHeight;
        default:
            return self.tableView.rowHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"DetailCell_%ld_%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = (UITableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } else {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        
        UILabel *titleLabel = [self createTitleLabel];
        titleLabel.text = self.cellTitles[indexPath.row];
        UILabel *valueLabel = [self createValueLabel:cell];
        valueLabel.text = self.cellValues[indexPath.row];
        
        switch (indexPath.row) {
            case 3:
            case 4:
            {
                titleLabel.frame = CGRectSetWidth(titleLabel.frame, noteHeight);
                valueLabel.frame = CGRectMake(cell.frame.size.width - cellPaddingX - 80, cellY, 80, cellHight);
                if ([self isNewRevision:valueLabel.text]) {
                    UILabel *newLabel = [UILabel new];
                    newLabel.font = [UIFont systemFontOfSize:10];
                    newLabel.text = @"new!!";
                    newLabel.textAlignment = NSTextAlignmentCenter;
                    newLabel.textColor = self.view.tintColor;
                    newLabel.layer.borderColor = [[UIColor colorWithRed:1.000 green:0.200 blue:0.400 alpha:1.000] CGColor];
                    newLabel.layer.borderWidth = 1;
                    newLabel.layer.cornerRadius = 3;
                    newLabel.frame = CGRectMake(cell.frame.size.width - valueLabel.frame.size.width - cellPaddingX - 30, cellY, 30, cellHight);
                    newLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                    [cell.contentView addSubview:newLabel];
                }
                break;
            }
                
            default:
                break;
        }
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:valueLabel];
    } else if (indexPath.section == 1) {
        UILabel *titleLabel = [self createMiddleTitleLabel];

        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            titleLabel.text = @"Status";
            UILabel *valueLabel = [self createValueLabelWithIndicator:cell];
            valueLabel.text = [DocumentEntity statusDescription:documentEntity.status];
            [cell.contentView addSubview:titleLabel];
            [cell.contentView addSubview:valueLabel];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = YES;

            titleLabel.text = @"Rate";
            [cell.contentView addSubview:titleLabel];

            UIImage *dot, *star;
            //            dot = [UIImage imageNamed:@"dot.png"];
            //            star = [UIImage imageNamed:@"star.png"];
            FAKIcon *dotIcon = [FAKFontAwesome starOIconWithSize:20];
            FAKIcon *starIcon = [FAKFontAwesome starIconWithSize:20];
            [dotIcon addAttribute:NSForegroundColorAttributeName value:self.view.tintColor];
            [starIcon addAttribute:NSForegroundColorAttributeName value:self.view.tintColor];
            dot = [dotIcon imageWithSize:CGSizeMake(20, 20)];
            star = [starIcon imageWithSize:CGSizeMake(20, 20)];
            AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(160, 5)
                                                                                  emptyImage:dot
                                                                                  solidImage:star
                                                                                andMaxRating:5];
            [imagesRatingControl addTarget:self action:@selector(updateEndRating:) forControlEvents:UIControlEventEditingDidEnd];
            [imagesRatingControl setRating:[documentEntity.rate intValue]];
            [imagesRatingControl setStarSpacing:10];
            imagesRatingControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [cell.contentView addSubview:imagesRatingControl];
        }
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
        
        noteTextView = [[RRPlaceholderTextView alloc]
                        initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 120)];
        noteTextView.delegate = self;
        noteTextView.editable = YES;
        noteTextView.keyboardType = UIKeyboardTypeDefault;
        noteTextView.text = documentEntity.note;
        noteTextView.placeholder = @"　ここはメモ欄です";
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        toolBar.tintColor = self.view.tintColor;
        toolBar.backgroundColor = [UIColor whiteColor];
        [toolBar sizeToFit];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeKeyboard:)];
        NSArray *items = [NSArray arrayWithObjects:spacer, done, nil];
        [toolBar setItems:items animated:YES];
        noteTextView.inputAccessoryView = toolBar;
        
        [cell.contentView addSubview:noteTextView];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"StatusSegue" sender:self];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PdfSegue"]) {
        RRPDFViewController *vc = segue.destinationViewController;
        vc.documentEntity = documentEntity;
    } else {
        RRStatusViewController *vc = segue.destinationViewController;
        vc.identifier = documentEntity.identifier;
        vc.selectedStatus = documentEntity.status;
    }
}

#pragma mark - UITextView

- (void)closeKeyboard:(id)sender
{
    [noteTextView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin toView:self.tableView];
    CGPoint contentOffset = self.tableView.contentOffset;
    contentOffset.y = (pointInTable.y - headerHeight);
    LOG(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
    [self.tableView setContentOffset:contentOffset animated:YES];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
//    FIXME: cellの値からindexPathが取得できない（なぜだかindexPath = nil となる）ので
//           indexPathを手動で設定。
//    UITableViewCell *cell = (UITableViewCell*)textView.superview.superview;
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];

    [self updateDocumentNote:textView.text];
    return YES;
}

#pragma mark -

/// 1ヶ月以内に更新されたかどうかを判定する
- (BOOL)isNewRevision:(NSString *)revision
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *revisionDate = [formatter dateFromString:revision];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:revisionDate];

    LOG(@"%f", interval / (24 * 60 * 60))
    return (interval / (24 * 60 * 60)) <= 30;
}

- (UILabel *)createTitleLabel
{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:12];
    label.frame = CGRectMake(cellPaddingX, cellY, 100, cellHight);
    label.textColor = [UIColor darkGrayColor];
    return label;
}

- (UILabel *)createValueLabel:(UITableViewCell *)cell
{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 7;
    label.frame = CGRectMake(cell.frame.size.width - cellPaddingX - 170, cellY, 170, cellHight);
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor darkGrayColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    return label;
}

- (UILabel *)createMiddleTitleLabel
{
    UILabel *label = [self createTitleLabel];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    return label;
}

- (UILabel *)createValueLabelWithIndicator:(UITableViewCell *)cell
{
    UILabel *label = [self createValueLabel:cell];
    label.frame = CGRectAddX(label.frame, - 7);
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return label;
}


#pragma mark - CoreData

- (void)updateDocumentNote:(NSString *)note
{
    NSDictionary *dict = @{@"title_jp":      documentEntity.title_jp,
                           @"note":          note
                           };
    [dataManager replace:[DocumentEntity class] dict:dict];
}

- (void)updateDocumentRate:(NSNumber *)rate
{
    NSDictionary *dict = @{@"title_jp":      documentEntity.title_jp,
                           @"rate":          rate
                           };
    [dataManager replace:[DocumentEntity class] dict:dict];
}

- (void)initilizeDocument
{
    NSDictionary *dict = @{@"title_jp":        documentEntity.title_jp,
                           @"download_status": @(DocumentDownloadStatusNone),
                           @"read_date":       [NSNull null],
                           @"status":          @(DocumentStatusUnread),
                           @"rate":            [NSNull null],
                           @"note":            @""
                           };
    [dataManager replace:[DocumentEntity class] dict:dict];
}

#pragma mark - Gesture

- (IBAction)tapGesture:(UIGestureRecognizer *)recognizer
{
    self.tapAreaView.backgroundColor = [UIColor lightGrayColor];
    [UIView animateWithDuration:0.3 animations:^{
        [self performSegueWithIdentifier:@"PdfSegue" sender:self];
    }];
}

- (IBAction)longPressGesture:(id)sender {
    if ([sender numberOfTouches] > 1) {
        return;
    }
    
    switch ([sender state]) {
        case UIGestureRecognizerStateBegan:
            self.tapAreaView.backgroundColor = [UIColor lightGrayColor];
            break;
        
        case UIGestureRecognizerStateChanged:
        {
            CGPoint touchPoint = [sender locationOfTouch:0 inView:self.view];
            if (CGRectContainsPoint(self.tapAreaView.frame, touchPoint)) {
                self.tapAreaView.backgroundColor = [UIColor lightGrayColor];
            } else {
                self.tapAreaView.backgroundColor = [UIColor whiteColor];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint touchPoint = [sender locationOfTouch:0 inView:self.view];
            if (CGRectContainsPoint(self.tapAreaView.frame, touchPoint)) {
                [self performSegueWithIdentifier:@"PdfSegue" sender:self];
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)swipeGesture:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ファイル情報を初期化します"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"キャンセル"
                                          otherButtonTitles:@"実行", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // core data更新
    [dataManager deleteOldDocuments:documentEntity];
    [self initilizeDocument];

    // データ再取得
    documentEntity = [dataManager find:[DocumentEntity class] byIdentifier:self.identifier];

    // 再描画
    self.sizeLabel.text = @"";
    self.downloadIconLabel.text = @"";
    [self.tableView reloadData];
}


#pragma mark - AMRatingControl

- (void)updateEndRating:(id)sender
{
    [self updateDocumentRate:@([(AMRatingControl *)sender rating])];
}

@end
