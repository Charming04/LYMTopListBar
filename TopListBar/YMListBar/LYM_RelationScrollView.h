//
//  LYM_RelationScrollView.h
//  Tan8Model
//
//  Created by Charming04 on 15/10/20.
//  Copyright © 2015年 12345. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYM_RelationScrollView : UIScrollView

//初始化,scrollView分页
-(instancetype)initWithFrame:(CGRect)frame withPage:(NSInteger)page;

//滚动结束的回调
-(void)didEndScroll:(void(^)(int position))block;

//关联滑动（scrollView滚动的位置）
-(void)didScroll:(void(^)(CGFloat scrollContentX))handel;

@end
