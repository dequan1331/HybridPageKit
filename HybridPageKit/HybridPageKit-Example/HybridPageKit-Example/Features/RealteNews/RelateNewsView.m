//
//  RelateNewsView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "RelateNewsView.h"
@interface RelateNewsView()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong,readwrite)UITableView *tableView;
@property(nonatomic,copy,readwrite)NSArray *relateData;
@end
@implementation RelateNewsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            _tableView =  [[UITableView alloc]initWithFrame:self.bounds];
            _tableView.delegate = self;
            _tableView.dataSource = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
            if (@available(iOS 11.0, *)){
                _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
#endif
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.scrollEnabled = NO;
            _tableView;
        })];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _tableView.frame = self.bounds;
    [_tableView reloadData];
}

-(void)layoutWithData:(RelateNewsModel *)relateNewsModel{

    if (relateNewsModel == nil || relateNewsModel.relateNewsArray == nil) {
        return;
    }
    
    _relateData = [relateNewsModel.relateNewsArray copy];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *text = [_relateData objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRelateNewsViewCellHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _relateData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelateNewsView"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RelateNewsView"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


@end
