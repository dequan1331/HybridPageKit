//
// RelateNewsView.m
//
// Copyright (c) 2019 dequanzhu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "RelateNewsView.h"

#define kRelateNewsViewCellHeight 60.f

@interface RelateNewsView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, copy, readwrite) NSArray *relateData;
@property (nonatomic, strong, readwrite) CALayer *topLine;
@end
@implementation RelateNewsView

IMP_HPKViewProtocol()

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:({
            _topLine = [[CALayer alloc]init];
            _topLine.backgroundColor = [UIColor colorWithRed:234.f / 255.f green:234.f / 255.f blue:234.f / 255.f alpha:1.f].CGColor;
            _topLine.frame = CGRectMake(0, 0, frame.size.width, 5);
            _topLine;
        })];
        [self addSubview:({
            _tableView =  [[UITableView alloc]initWithFrame:self.bounds];
            _tableView.delegate = self;
            _tableView.dataSource = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
            if (@available(iOS 11.0, *)) {
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _topLine.frame = CGRectMake(0, 0, frame.size.width, 5);
    _tableView.frame =CGRectMake(0, _topLine.frame.size.height, frame.size.width, frame.size.height - 5);
    [_tableView reloadData];
}

- (void)layoutWithData:(RelateNewsModel *)relateNewsModel {
    if (relateNewsModel == nil || relateNewsModel.relateNewsArray == nil) {
        return;
    }

    _relateData = [relateNewsModel.relateNewsArray copy];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kRelateNewsViewCellHeight * _relateData.count + 5);
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [_relateData objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRelateNewsViewCellHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _relateData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelateNewsView"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RelateNewsView"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat)componentHeight {
    return kRelateNewsViewCellHeight * _relateData.count;
}

@end
