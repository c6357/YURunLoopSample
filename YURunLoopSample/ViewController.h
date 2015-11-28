//
//  ViewController.h
//  YURunLoopSample
//
//  Created by BruceYu on 15/03/05.
//  Copyright © 2015年 BruceYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

#ifndef	weakify
#if __has_feature(objc_arc)
#define weakify( x )	autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x;
#else
#define weakify( x )	autoreleasepool{} __block __typeof__(x) __block_##x##__ = x;
#endif
#endif

#ifndef	strongify
#if __has_feature(objc_arc)
#define strongify( x )	try{} @finally{} __typeof__(x) x = __weak_##x##__;
#else
#define strongify( x )	try{} @finally{} __typeof__(x) x = __block_##x##__;
#endif
#endif


#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)


#define SWF(S, args...)[NSString stringWithFormat:S,args]