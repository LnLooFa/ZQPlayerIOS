//
//  ThreadTestViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/18.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ThreadTestViewController.h"
#import <pthread.h>

@interface ThreadTestViewController ()

@end

@implementation ThreadTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pthreadRun:(id)sender {
    pthread_t thread2;
    pthread_create(&thread2, NULL, run1, NULL);
}

void * run1(void * param){
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"---pthread Run---%zd---%@", i, [NSThread currentThread]);
    }
    return NULL;
}

- (IBAction)nsThreadRun:(id)sender {
    [self createThreadWithImplicit];
//    [self createThreadWithClassMethod];
//    [self createThreadWithInit];
}


- (void)threadMethod {
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"---nsThread Run---%zd---%@", i, [NSThread currentThread]);
    }
}

/**
 *  隐式创建并启动线程
 */
- (void)createThreadWithImplicit {
    // 隐式创建并启动线程
    [self performSelectorInBackground:@selector(threadMethod) withObject:@"implicitMethod"];
}

/**
 *  使用NSThread类方法显式创建并启动线程
 */
- (void)createThreadWithClassMethod {
    // 使用类方法创建线程并自动启动线程
    [NSThread detachNewThreadSelector:@selector(threadMethod) toTarget:self withObject:@"fromClassMethod"];
}

/**
 *  使用init方法显式创建线程
 */
- (void)createThreadWithInit {
    // 创建线程
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(threadMethod) object:nil];
    // 设置线程名
    [thread1 setName:@"thread1"];
    // 设置优先级 优先级从0到1 1最高
    [thread1 setThreadPriority:0.9];
    // 启动线程
    [thread1 start];
}

- (IBAction)dispatchRun:(id)sender {
    // 主队列的获取方法
    dispatch_queue_t queueMain = dispatch_get_main_queue();
    // 全局并发队列的获取方法
    dispatch_queue_t queueGlobal = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queueGlobal, ^{
            
                NSLog(@"---dispatch_async Run---%zd---%@", i, [NSThread currentThread]);
            
        });
    }
}


- (IBAction)nsOperationRun:(id)sender {
//    [self useInvocationOperation];//在主线程阻塞了
    // 在其他线程使用子类 NSInvocationOperation
//    [NSThread detachNewThreadSelector:@selector(useInvocationOperation) toTarget:self withObject:nil];
    
//    [self useBlockOperation];//在主线程阻塞了
//    [self addOperationToQueue];
    [self communication];
}

/**
 * 线程间通信
 */
- (void)communication {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}

/**
 * 使用 addOperation: 将操作加入到操作队列中
 */
- (void)addOperationToQueue {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    // 使用 NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    
    // 使用 NSInvocationOperation 创建操作2
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    
    // 使用 NSBlockOperation 创建操作3
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.使用 addOperation: 添加所有操作到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    [queue addOperation:op3]; // [op3 start]
}


/**
 * 使用子类 NSBlockOperation
 */
- (void)useBlockOperation {
    
    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"---useBlockOperation Run---%zd---%@", i, [NSThread currentThread]);
        }
    }];

    // 2.调用 start 方法开始执行操作
    [op start];
}

/**
 * 使用子类 NSInvocationOperation
 */
- (void)useInvocationOperation {
    
    // 1.创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    // 2.调用 start 方法开始执行操作
    [op start];
}



/**
 * 任务1
 */
- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"---nsOperation Run---%zd---%@", i, [NSThread currentThread]);
    }
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
