//
//  ViewController.m
//  ZLCoverView
//
//  Created by 炸药 on 2/7/20.
//  Copyright © 2020 炸药. All rights reserved.
//

#import "ViewController.h"
#import "CoverViewer.h"
@interface ViewController ()<CoverViewerDelegate>
@property (nonatomic,strong)CoverViewer         *coverViewer;//滚动视图动画
@property (nonatomic,strong)NSMutableArray         *dataArray;
@property (nonatomic,strong)UIView         *detailView;
@property (nonatomic,strong)UILabel *nameLabe;

@end

@implementation ViewController
-(NSMutableArray *)dataArray{
    
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.orangeColor;
    [self getData];
    self.coverViewer = [[CoverViewer alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 224)];
    self.coverViewer.delegate = self;
    self.coverViewer.backgroundColor = [UIColor clearColor];
    self.coverViewer.rightLimit = [UIScreen mainScreen].bounds.size.width/166;
    [self.view addSubview:self.coverViewer];
    
    self.detailView = [[UIView alloc]initWithFrame:CGRectMake(0, 450, [UIScreen mainScreen].bounds.size.width, 80)];
    self.detailView.backgroundColor = UIColor.purpleColor;
    [self.view addSubview:self.detailView];
    
    self.nameLabe = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 40)];
    self.nameLabe.textColor = UIColor.blackColor;
    self.nameLabe.font = [UIFont systemFontOfSize:15];
    self.nameLabe.text = [self.dataArray[0]objectForKey:@"title"];

    [self.detailView addSubview:self.nameLabe];
}
-(void)getData{
    NSArray *arr = @[@{@"imageName":@"cover0.jpg",@"title":@"第1张"},@{@"imageName":@"cover1.jpg",@"title":@"第2张"},@{@"imageName":@"cover2.jpg",@"title":@"第3张"},@{@"imageName":@"cover3.jpg",@"title":@"第4张"},@{@"imageName":@"cover4.jpg",@"title":@"第5张"}];
    for (int i = 0; i<5; i++) {
        NSDictionary *dic = arr[i];
        
        [self.dataArray addObject:dic];
    }
    [self.coverViewer reloadDatas];

}
- (NSInteger)coverViewerCount:(CoverViewer *)coverViewer{
    
    return self.dataArray.count;

}
- (UIImageView *)coverViewer:(CoverViewer*)coverViewer coverAtIndex:(NSInteger)index {
    UIImageView *view = [coverViewer dequeueItemView];
    if (!view) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 150, 224)];
        view.layer.cornerRadius = 4;
        view.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClicked:)];
        [view addGestureRecognizer:tap];
        view.userInteractionEnabled = YES;
    }
    view.tag = index;
    //这个地方可以加载网络图片
    [view setImage:[UIImage imageNamed:[self.dataArray[index]objectForKey:@"imageName"]]];
//    [view sd_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholderImage:[UIImage imageNamed:@"loadingplacehi"]];

    return view;
}
- (void)itemClicked:(UITapGestureRecognizer *)tap {
    [_coverViewer setContentOffset:tap.view.tag animated:YES];
    UIImageView *view = (UIImageView *)tap.view;
    NSLog(@"%ld",view.tag);

//    self.currentScrollIndex = tap.view.tag;
//    MahuaHotItemMovieModel *model = self.movieArray[tap.view.tag];
    if (view.frame.size.width == 150 && view.frame.size.height == 224) {
        //点击的时候判断尺寸 根据尺寸来判断是否点击了最大的图片
        NSLog(@"点击了最大的图片");

    }else{
      //如果不是最大的 就做UI上的处理 （改变ui尺寸 等等）
        self.nameLabe.text = [self.dataArray[view.tag]objectForKey:@"title"];

    }
}
-(void)passCurrentScrollIndex:(NSInteger)currentIndex{
    
    NSLog(@"%ld",currentIndex);
    self.nameLabe.text = [self.dataArray[currentIndex]objectForKey:@"title"];

}

@end
