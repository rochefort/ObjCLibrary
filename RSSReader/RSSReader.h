//
//  RSSReader.h
//  RSSReader
//
//  Created by rochefort on 2013/10/26.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#ifndef RSSReader_RSSReader_h
#define RSSReader_RSSReader_h
    #import "RRUtils.h"
    #import "UIImage+UIImage_blur.h"
    #import "RRDataManager.h"
    #import "DocumentEntity.h"
    #import "DocumentEntity+Extensions.h"
    #import "DownloadEntity.h"

    // CGRectにXをセット
    #define CGRectSetX(r, x)                    CGRectMake(x, r.origin.y, r.size.width, r.size.height)

    // CGRectにYをセット
    #define CGRectSetY(r, y)                    CGRectMake(r.origin.x, y, r.size.width, r.size.height)

    // CGRectに幅をセット
    #define CGRectSetWidth(r, w)                CGRectMake(r.origin.x, r.origin.y, w, r.size.height)

    // CGRectに高さをセット
    #define CGRectSetHight(r, h)                CGRectMake(r.origin.x, r.origin.y, r.size.width, h)

    // CGRectにXを加算
    #define CGRectAddX(r, dx)                   CGRectMake(r.origin.x + dx, r.origin.y, r.size.width, r.size.height)

    // CGRectにYを加算
    #define CGRectAddY(r, dy)                   CGRectMake(r.origin.x, r.origin.y + dy, r.size.width, r.size.height)

    // CGRectに幅を加算
    #define CGRectAddWidth(r, dw)               CGRectMake(r.origin.x, r.origin.y, r.size.width + dw, r.size.height)

    // CGRectに高さを加算
    #define CGRectAddHight(r, dh)               CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height + dh)

#endif
