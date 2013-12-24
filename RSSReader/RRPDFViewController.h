//
//  RRPDFViewController.h
//  RSSReader
//
//  Created by rochefort on 2013/11/02.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRPDFViewController : UIViewController<UIDocumentInteractionControllerDelegate>
@property (nonatomic) DocumentEntity *documentEntity;
@end
