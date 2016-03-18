//
//  ViewController.m
//  TopListBar
//
//  Created by Charming04 on 16/3/18.
//  Copyright © 2016年 Charming04. All rights reserved.
//

#import "ViewController.h"
#import "LYM_TopListBar.h"
#import "LYM_RelationScrollView.h"

@interface ViewController ()

@end

@implementation ViewController{
    LYM_TopListBar *mb_topbar;
    LYM_RelationScrollView *mb_relscrollV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    ////////////生成一个toplistBar//////////////////
    NSArray *titlesArr = @[@"热门", @"秀场",  @"问答", @"日记", @"科技苑", @"数码", @"其他"];
    mb_topbar = [[LYM_TopListBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40) itemTitle:titlesArr];
    [self.view addSubview:mb_topbar];
    
    
    
    /////////////生成一个关联的relscrollV/////////////
    mb_relscrollV = [[LYM_RelationScrollView alloc]initWithFrame:CGRectMake(0, 60,self.view.frame.size.width , 200) withPage:titlesArr.count];
    [self.view addSubview:mb_relscrollV];
    
    

    //以下三个回调代码实现关联滑动（如果不做关联滑动的话，不需要实现下面的回调方法）
    __weak typeof(mb_topbar)weakTopbar = mb_topbar;
    __weak typeof(mb_relscrollV)weakScroll = mb_relscrollV;
    [mb_relscrollV didScroll:^(CGFloat scrollContentX) {
        [weakTopbar scrollView:weakScroll didLandScapeScroll:scrollContentX];
    }];
    
    [mb_relscrollV didEndScroll:^(NSInteger position) {
        [weakTopbar selectItem:position];
    }];
    
    [mb_topbar itemDidClicked:^(int position) {
        [weakScroll setContentOffset:CGPointMake(weakScroll.bounds.size.width * position, 0) animated:YES];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
