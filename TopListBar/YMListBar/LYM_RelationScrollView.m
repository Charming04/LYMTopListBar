//
//  LYM_RelationScrollView.m
//  Tan8Model
//
//  Created by Charming04 on 15/10/20.
//  Copyright © 2015年 12345. All rights reserved.
//

#import "LYM_RelationScrollView.h"

@interface LYM_RelationScrollView()<UIScrollViewDelegate>{
    void(^mb_didEndScroll)(NSInteger);
    void(^mb_scrollContentX)(CGFloat);
    NSInteger mb_position;
}
@end

@implementation LYM_RelationScrollView

#pragma mark - 初始化
-(instancetype)initWithFrame:(CGRect)frame withPage:(NSInteger)page{
    if (self = [super initWithFrame:frame]) {
        //scrollView的特性
        self.pagingEnabled = YES;
        self.delegate = self;
        self.bounces = NO;
        self.contentSize = CGSizeMake(frame.size.width * page, frame.size.height);
        mb_position = 0;
        self.scrollsToTop = NO;
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

#pragma mark - 滚动结束的回调
-(void)didEndScroll:(void (^)(NSInteger))block{
    if (block) {
        mb_didEndScroll = [block copy];
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewEndScroll:scrollView];
} 
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewEndScroll:scrollView];
}

-(void)scrollViewEndScroll:(UIScrollView *)scrollView{
    NSInteger position = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (position == mb_position) {
        return;
    }else{
        mb_position = position;
    }
    if (mb_didEndScroll) {
        mb_didEndScroll(scrollView.contentOffset.x / scrollView.bounds.size.width);
    }
}

-(void)didScroll:(void (^)(CGFloat))handel{
    mb_scrollContentX = [handel copy];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (mb_scrollContentX) {
        mb_scrollContentX(scrollView.contentOffset.x);
    }
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    int currentPostion = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
//
//    if (currentPostion >= 0 && (currentPostion != mb_position)) {
//        mb_position = currentPostion;
//        if (mb_didEndScroll) {
//            mb_didEndScroll(mb_position);
//        }
//    }
//}

@end
