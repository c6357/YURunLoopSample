//
//  ViewController.m
//  YURunLoopSample
//
//  Created by BruceYu on 15/03/05.
//  Copyright © 2015年 BruceYu. All rights reserved.
//

#import "ViewController.h"
@interface ViewController (){
    NSInteger coldDown1;
    NSInteger coldDown2;
    BOOL runSubThreadEnd;
}
@property (strong,nonatomic)NSTimer *timer1;
@property (strong,nonatomic)NSTimer *timer2;
@property (weak, nonatomic) IBOutlet UILabel *lab;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    coldDown1 = coldDown2 = 15;
    
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandler1:) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer1 forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)mainUpdateUI:(id)sender {
    
    //    [self runloopBlock];
    MAIN(^{
        sleep(3);
    });
    [self.btn setTitle:@"主线程更新UI结束" forState:UIControlStateNormal];
}


- (IBAction)action:(id)sender {
    
    [self runloopSubThread];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    });
}

- (void)timerHandler1:(NSTimer *)sender
{
    @weakify(self);
    MAIN(^{
        @strongify(self);
        if (--coldDown1 == 0) {
            //[self.timer invalidate];
        }
        self.title = SWF(@"主线程:%@",@(coldDown1));
    });
}

-(void)setMsg{
     self.lab.text = SWF(@"子线程:%@",@(coldDown2));
}


- (void)timerHandler2:(NSTimer *)sender{
    
    if (![NSThread isMainThread]) {
        NSLog(@"子线程");
        if (--coldDown2 == 0) {
            //            [self.timer invalidate];
        }
#warning 主线程操作数据
//         MAIN(^{
        self.lab.text = SWF(@"子线程:%@",@(coldDown2));
//              });
//          [self performSelectorOnMainThread:@selector(setMsg) withObject:nil waitUntilDone:NO];
    }
    
#if 0
    @weakify(self);
    MAIN(^{
        if ([NSThread isMainThread]) {
            @strongify(self);
            if (--coldDown2 == 0) {
                //            [self.timer invalidate];
            }
            self.lab.text = SWF(@"主线程:%@",@(coldDown2));
        }
    });
#endif
}


/**
 *  runloop阻塞线程
 */
-(void)runloopBlock{
    
    //    [self performSelectorInBackground:@selector(subThread) withObject:nil];
    //    [NSThread detachNewThreadSelector:@selector(subThread) toTarget:self withObject:nil]
    //    @weakify(self);
    //    BACK(^{
    //        @strongify(self)
    [self subThread];
    //    });
    
    while (!runSubThreadEnd) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    
    NSLog(@"run subThread end …");
}
-(void)subThread{
    NSLog(@"run for subThread …");
    sleep(3);
    runSubThreadEnd = YES;
}

/**
 * 子线程使用NSTimer
 */
-(void)runloopSubThread{
    @weakify(self);
    
    //    NSLog(@"mainRunLoop %@",[NSRunLoop mainRunLoop]);
    BACK(^{
        @strongify(self);
        [self.timer2 invalidate];
        self.timer2 = nil;
        coldDown2 = 15;
        self.timer2 = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerHandler2:) userInfo:nil repeats:YES];
        //将定时器添加到runloop中
        [[NSRunLoop currentRunLoop] addTimer:self.timer2 forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

@end
