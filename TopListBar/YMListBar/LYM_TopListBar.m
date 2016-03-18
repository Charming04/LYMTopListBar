//
//  LYM_TopListBar.m
//  testTopBar
//
//  Created by Charming on 15/9/10.
//  Copyright (c) 2015年 Charming. All rights reserved.
//

#import "LYM_TopListBar.h"
#define RGB(r,g,b)   [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0];

@implementation LYM_TopListBar{
    UIScrollView    *mb_relativeScrollView;//关联的ScrollView,不关联为nil
    UIButton        *mb_selectBtn;      //选中的btn
    NSMutableArray  *mb_itemTitles;
    NSMutableArray  *mb_itemTitleWidths;
    NSMutableArray  *mb_items;
    int             mb_position;
    void(^mb_itemDidClicked)(int position);
    BOOL            mb_flag;//swithToNewPositonHandel控制这个方法每次只调用一次即可
}

#pragma mark - //////////初始化方法/////////////
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _mb_topBarHeight = frame.size.height;
        _mb_topBarWidth = frame.size.width;
        _mb_itemDistance = 25;            //item左右两端距离title的距离
        _mb_itemFontSize = 16;            //item的字体
        _mb_topBarBackgroundColor = RGB(245, 245, 245);
        _mb_itemSelectColor = RGB(212, 62, 51);
        _mb_itemNomarlColor = RGB(102, 102, 102);
        _mb_indicatorColor = RGB(212, 62, 51);
        
        mb_items = [@[] mutableCopy];//btns
        mb_itemTitleWidths  =[@[] mutableCopy];
        mb_itemDidClicked = nil;
        mb_position = 0;   //位置为0
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame itemTitle:(NSArray *)itemsTitles{
    
    if (self = [self initWithFrame:frame]) {
        //1.初始化
        mb_itemTitles = [[NSMutableArray alloc]initWithArray:itemsTitles]; //titles
        
        //2.topbar
        _mb_topScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _mb_topScrollView.backgroundColor = _mb_topBarBackgroundColor;
        _mb_topScrollView.showsHorizontalScrollIndicator = NO;
        _mb_topScrollView.alwaysBounceVertical = NO;
        _mb_topScrollView.scrollsToTop = NO;
        [self addSubview:_mb_topScrollView];
        
        //3.item,indicator
        CGFloat contentWidth = [self ceateItemsAndIndicator:itemsTitles];
        if (contentWidth < _mb_topBarWidth) {
            contentWidth = _mb_topBarWidth;
        }
        _mb_topScrollView.contentSize = CGSizeMake(contentWidth, _mb_topBarHeight);
        
        //4.bottomLine、topLine
        CGFloat tempSide = 1/[UIScreen mainScreen].scale;//获取该设备下最新的线的边长
        UIView *bottomLineV = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mb_topScrollView.frame) - tempSide, self.frame.size.width, tempSide)];
        bottomLineV.backgroundColor = RGB(178, 178, 178);
        [self addSubview:bottomLineV];
        [self bringSubviewToFront:bottomLineV];
        _mb_bottomLine = bottomLineV;
        
        UIView *topLineV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, tempSide)];
        topLineV.backgroundColor = RGB(178, 178, 178);
        [self addSubview:topLineV];
        [self bringSubviewToFront:topLineV];
        _mb_topLine = topLineV;
    }
    return self;
}

#pragma mark - ///////修改选中items中btn的选中颜色/////////
-(void)setMb_itemSelectColor:(UIColor *)mb_itemSelectColor{
    _mb_itemSelectColor = mb_itemSelectColor;
    
    //遍历items
    for (int i = 0; i<mb_items.count; i++) {
        [((UIButton *)mb_items[i]) setTitleColor:mb_itemSelectColor forState:UIControlStateSelected];
    }
}

#pragma mark - ///////修改items中btn的默认颜色
-(void)setMb_itemNomarlColor:(UIColor *)mb_itemNomarlColor{
    _mb_itemNomarlColor = mb_itemNomarlColor;
    
    //遍历items
    for (int i = 0; i<mb_items.count; i++) {
        [((UIButton *)mb_items[i]) setTitleColor:mb_itemNomarlColor forState:UIControlStateNormal];
    }
}

#pragma mark - ///////修改indicator的颜色
-(void)setMb_indicatorColor:(UIColor *)mb_indicatorColor{
    _mb_indicatorColor = mb_indicatorColor;
    
    //设置颜色
    [_mb_indicatorView setBackgroundColor:mb_indicatorColor];
}

#pragma mark - //////创建item (title, index)////////
-(CGFloat)ceateItemsAndIndicator:(NSArray *)itemTitles{
    
    //1.item
    CGFloat itemsWidth = 0;
    for (int i = 0; i < itemTitles.count; i++) {
        CGFloat titleW = [self calculateSizeWithFont:_mb_itemFontSize Text:itemTitles[i]].size.width;              //title的宽
        [mb_itemTitleWidths addObject:@(titleW)];
        CGFloat itemW = titleW + _mb_itemDistance;
        itemsWidth += itemW;
        //item的宽
        UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(itemsWidth - itemW, 0, itemW, _mb_topBarHeight)];   //创建不同位置的item
        item.titleLabel.font = [UIFont systemFontOfSize:_mb_itemFontSize];
        [item setTitle:itemTitles[i] forState:UIControlStateNormal];
        item.selected = NO;
        item.tag = i;
        [item setTitleColor:_mb_itemNomarlColor forState:UIControlStateNormal];
        [item setTitleColor:_mb_itemSelectColor forState:UIControlStateSelected];
        [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        [mb_items addObject:item];
        [_mb_topScrollView addSubview:item];
    }
    //1.1如果总宽度不够屏幕的宽度
    CGFloat allAddWidth = 0;
    if(itemsWidth < _mb_topBarWidth){//重新布局
        //1.少的长度
        CGFloat adjustWidth = _mb_topBarWidth - itemsWidth;
        //2.按比例平分adjustWidth;
        for (int i = 0; i < itemTitles.count; i++) {
            UIButton *item = mb_items[i];
            CGFloat itemW = item.frame.size.width;
            CGFloat addWidth =  itemW/itemsWidth * adjustWidth;
            //3.布局
            item.frame = CGRectMake(item.frame.origin.x + allAddWidth, item.frame.origin.y, addWidth + itemW, item.frame.size.height);
            allAddWidth += addWidth;
        }
    }
    
    //2.indicator
    if (_mb_indicatorView == nil) {
        _mb_indicatorView = [[UIView alloc]init];
        _mb_indicatorView.layer.cornerRadius = 5;
        _mb_indicatorView.backgroundColor = _mb_indicatorColor;
        [_mb_topScrollView addSubview:_mb_indicatorView];
        
        [self caluIndicatorPosition:0];
    }
    
    //3.默认选中第一个item
    mb_selectBtn = mb_items[0];
    mb_selectBtn.selected = YES;

    return itemsWidth;
}


#pragma mark - //////////计算indicator的位置////////
-(void)caluIndicatorPosition:(NSInteger)index{
    UIButton *tmpBtn = mb_items[index];
    CGFloat btnW = tmpBtn.frame.size.width;
    CGFloat btnX = tmpBtn.frame.origin.x;
    CGFloat titleW = [mb_itemTitleWidths[index]floatValue];
    CGFloat padX = 0.5 * (btnW - titleW) + btnX - _mb_itemDistance/ 4;

    NSTimeInterval duration = 0.2;
    if (index == mb_position) {
        duration = 0;
    }
    
    [UIView animateWithDuration:duration animations:^{
        _mb_indicatorView.frame = CGRectMake(padX, _mb_topBarHeight - 2, titleW + 0.5 * _mb_itemDistance, _mb_topBarHeight);
    }];
}


#pragma mark - ///////////item点击事件///////////
-(void)itemClick:(UIButton *)sender{
    if (sender.tag == mb_selectBtn.tag) {
        return;
    }
    
    [self swithToNewPositonHandel:sender];
}
-(void)itemDidClicked:(void (^)(int))callback{
    if (callback) {
        mb_itemDidClicked = [callback copy];
    }
}

-(void)swithToNewPositonHandel:(UIButton *)sender{
    
    NSInteger tmpTag = sender.tag;
    
    if(mb_relativeScrollView == nil){
        //1.改变btn的颜色
        mb_selectBtn.selected = NO;
        sender.selected = YES;
        //2.该变indicator的frame
        [self caluIndicatorPosition:tmpTag];
        [self adjustTopScrollPosition:tmpTag];
        mb_position = (int)tmpTag;
    }
    
    mb_selectBtn = sender;
    if (mb_itemDidClicked) {
        mb_itemDidClicked((int)tmpTag);
    }
}

#pragma mark - //////////计算字符串的宽////////////
-(CGRect)calculateSizeWithFont:(NSInteger)Font Text:(NSString *)Text{
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font]};
    CGRect size = [Text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                     options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attr
                                     context:nil];
    return size;
}

#pragma mark - 调整topbar的位置
-(void)adjustTopScrollPosition:(NSInteger)postion{
    
    if(postion == 0 && _mb_topScrollView.contentOffset.x == 0){
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self changeScrollViewPostion:postion];
    }];
}

-(void)changeScrollViewPostion:(NSInteger)postion{
    UIButton *tmpBtn = mb_items[postion];
    CGPoint changePoint;
    if (tmpBtn.center.x >= _mb_topBarWidth * 0.5 && tmpBtn.center.x < _mb_topScrollView.contentSize.width- _mb_topBarWidth * 0.5) {
        changePoint = CGPointMake(tmpBtn.center.x - _mb_topBarWidth * 0.5, 0);
    }else if (tmpBtn.center.x >= _mb_topScrollView.contentSize.width - _mb_topBarWidth * 0.5){
        changePoint = CGPointMake(_mb_topScrollView.contentSize.width-_mb_topBarWidth, 0);
    }else{
        changePoint = CGPointMake(0, 0);
    }
    _mb_topScrollView.contentOffset = changePoint;
}

#pragma mark - //////选中某个item的处理//////
-(BOOL)selectItem:(NSInteger)index{
    if (index < 0 || index >= mb_items.count) {
        index = 0;
    }
    if (index >= 0 && index < mb_items.count && index != mb_selectBtn.tag) {
        UIButton *sender = mb_items[index];
        [self swithToNewPositonHandel:sender];
    }else{//修正topbar的位置(带动画)
        [self adjustTopScrollPosition:index];
    }
    if (index == mb_position) {
        return NO;
    }
    return YES;
}

#pragma mark - 获取当期的位置
-(NSInteger)getCurrentPosition{
    return mb_position;
}

#pragma mark - 关联滑动
-(void)scrollView:(UIScrollView*)scrollView didLandScapeScroll:(CGFloat)offsetX{
    //0.关联上
    mb_relativeScrollView = scrollView;
    
    //1.计算center
    CGFloat scrollWidth = scrollView.frame.size.width;
    int index = offsetX/scrollWidth;
    if (index+1 == mb_items.count) {
        index--;
    }
    
    UIButton *nearLeftBtn = mb_items[index];
    UIButton *nearRightBtn = mb_items[index + 1];
    
    CGFloat nearBtnDistance = nearRightBtn.center.x - nearLeftBtn.center.x;
    CGFloat smallOffsetX = offsetX - scrollWidth * index;
    CGFloat indicatorCenterX = smallOffsetX/scrollWidth * nearBtnDistance + nearLeftBtn.center.x;
    
    //2.计算滑动条的大小
    int position = (offsetX + scrollWidth * 0.5) / scrollWidth;
    
    if (mb_position != position) {
        ((UIButton *)mb_items[mb_position]).selected = NO;
        mb_position = position;
    }
    if (position == mb_items.count) {
        position--;
    }
    
    mb_selectBtn.selected = NO;
    mb_selectBtn = mb_items[position];
    mb_selectBtn.selected = YES;
    
    CGFloat currentBtnCenterX = mb_selectBtn.center.x;
    
    UIButton *leftBtn = nil;
    UIButton *rightBtn = nil;
    CGFloat leftBtnTitleWidth = 0;
    CGFloat rightBtnTitleWidth = 0;
    CGFloat indicatorWidth = 0;
    
    if (indicatorCenterX > currentBtnCenterX) {
        leftBtn = mb_selectBtn;
        rightBtn = mb_items[position + 1];

        rightBtn.selected = NO;
        leftBtn.selected = YES;

        leftBtnTitleWidth = [mb_itemTitleWidths[position] floatValue] + 0.5 * _mb_itemDistance;
        rightBtnTitleWidth = [mb_itemTitleWidths[position + 1] floatValue] + 0.5 * _mb_itemDistance;
        indicatorWidth = (indicatorCenterX - leftBtn.center.x) * (rightBtnTitleWidth - leftBtnTitleWidth) / (rightBtn.center.x - leftBtn.center.x) + leftBtnTitleWidth;
        
    }else if(indicatorCenterX < currentBtnCenterX){
        rightBtn = mb_selectBtn;
        leftBtn = mb_items[position - 1];

        leftBtn.selected = NO;
        rightBtn.selected = YES;
        
        leftBtnTitleWidth = [mb_itemTitleWidths[position - 1] floatValue] + 0.5 * _mb_itemDistance;
        rightBtnTitleWidth = [mb_itemTitleWidths[position] floatValue] + 0.5 * _mb_itemDistance;
        
        indicatorWidth = (indicatorCenterX - leftBtn.center.x) * (rightBtnTitleWidth - leftBtnTitleWidth) / (rightBtn.center.x - leftBtn.center.x) + leftBtnTitleWidth;
        
    }else{
        indicatorWidth = [mb_itemTitleWidths[position] floatValue] + 0.5 * _mb_itemDistance;
    }
    
    //3.显示滑动条
    CGRect rect = _mb_indicatorView.frame;
    rect.size.width = indicatorWidth;
    _mb_indicatorView.frame = rect;
    
    CGPoint center = _mb_indicatorView.center;
    center.x = indicatorCenterX;
    _mb_indicatorView.center = center;
}

@end
