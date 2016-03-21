//
//  LYM_TopListBar.h
//  testTopBar
//
//  Created by Charming on 15/9/10.
//  Copyright (c) 2015年 Charming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYM_TopListBar : UIView

//控件
@property(nonatomic,strong)UIScrollView    *mb_topScrollView;  //topBarScrollView
@property(nonatomic,strong)UIView          *mb_indicatorView;  //标注item选中后的指示器
@property(nonatomic,strong)UIView          *mb_bottomLine;
@property(nonatomic,strong)UIView          *mb_topLine;


@property(nonatomic,assign)CGFloat         mb_itemDistance;            //item左右两端距离title的距离
@property(nonatomic,assign)int             mb_itemFontSize;            //item的字体
@property(nonatomic,assign)CGFloat         mb_topBarHeight;            //topbar的高度
@property(nonatomic,assign)CGFloat         mb_topBarWidth;             //topbar的宽度
@property(nonatomic,strong)UIColor         *mb_topBarBackgroundColor;  //topbar背景颜色
@property(nonatomic,strong)UIColor         *mb_itemSelectColor;        //item选中颜色
@property(nonatomic,strong)UIColor         *mb_itemNomarlColor;        //item正常颜色
@property(nonatomic,strong)UIColor         *mb_indicatorColor;         //indicator颜色

//传入item的title,构建topbar的数据源
-(instancetype)initWithFrame:(CGRect)frame itemTitle:(NSArray *)itemsTitles;

//构建关联滑动的topBar
-(instancetype)initWithFrame:(CGRect)frame itemTitle:(NSArray *)itemsTitles relScrollView:(UIScrollView*)scrollView;

//item选中后的回调事件
-(void)itemDidClicked:(void(^)(int position))callback;

//跳转到第N个item（从0开始）,如果位置不变，返回NO,位置改变返回YES
-(BOOL)selectItem:(int)index;

//获取当前的位置
-(NSInteger)getCurrentPosition;

//关联滑动
-(void)scrollView:(UIScrollView*)scrollView didLandScapeScroll:(CGFloat)offsetX;

@end
