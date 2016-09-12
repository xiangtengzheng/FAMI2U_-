//
//  CommentsCell.m
//  评论
//
//  Created by ZhengXiangteng on 16/4/5.
//  Copyright © 2016年 前辈丶. All rights reserved.
//

#define Main_WIDTH [[UIScreen mainScreen] bounds].size.width

//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND
//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"
#import "CommentsCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"


@interface CommentsCell ()

@property (nonatomic, strong) UIImageView *head;   //头像
@property (nonatomic, strong) UILabel *name;       //昵称
@property (nonatomic, strong) UILabel *date;       //日期
@property (nonatomic, strong) UILabel *comments;   //评论
@property (nonatomic, strong) UILabel *reply;      //回复

/** 九宫格view */
@property (nonatomic, strong) UIView *buttonView;

@end

@implementation CommentsCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"comments";
    CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[CommentsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *head = [[UIImageView alloc]init];
//        head.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:head];
        self.head = head;
        [head makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(10);
            make.size.equalTo(40);
        }];
        
        UILabel *name = [[UILabel alloc]init];
        name.font = [UIFont systemFontOfSize:15];
//        name.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:name];
        self.name = name;
        [name makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(head.right).equalTo(10);
            make.height.equalTo(20);
            make.centerY.equalTo(head);
        }];
        
        UILabel *date = [[UILabel alloc]init];
        date.textColor = [UIColor lightGrayColor];
        date.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:date];
        self.date = date;
        [date makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(-20);
            make.height.equalTo(20);
            make.centerY.equalTo(head);
        }];
        
        UILabel *comments = [[UILabel alloc]init];
//        comments.backgroundColor = [UIColor yellowColor];
        comments.font = [UIFont systemFontOfSize:14];
        comments.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 20;
        comments.numberOfLines = 0;
        [self.contentView addSubview:comments];
        self.comments = comments;
        [comments makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(head.bottom).offset(10);
            make.left.equalTo(10);
            make.right.equalTo(-10);
        }];
        
        UIView *buttonView = [[UIView alloc]init];
        [self.contentView addSubview:buttonView];
        self.buttonView = buttonView;
        //图片的宽和高
        float imgW=(Main_WIDTH-100)/3;
        for (int i = 0; i < 9; i++) {
            UIButton *button = [[UIButton alloc]init];
            button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            button.tag = i + 1000;
            button.hidden = YES;
            CGFloat buttonX = imgW * (i % 3) ;
            CGFloat buttonY = imgW * (i / 3) ;
            CGFloat markX = 10 * (i % 3);
            CGFloat markY = 10 * (i / 3);
            button.frame = CGRectMake(buttonX + markX , buttonY + markY, imgW, imgW);
//            button.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
            [buttonView addSubview:button];
            [button addTarget:self action:@selector(searcimage:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [buttonView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(comments.bottom).offset(10);
            make.left.equalTo(10);
            make.size.equalTo(imgW * 3 + 20);
        }];
        
        UILabel *reply = [[UILabel alloc]init];
//        reply.backgroundColor = [UIColor cyanColor];
        reply.font = [UIFont systemFontOfSize:14];
        reply.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 20;
        reply.numberOfLines = 0;
        [self.contentView addSubview:reply];
        self.reply = reply;
        [reply makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(buttonView.bottom).offset(10);
            make.left.equalTo(10);
            make.right.equalTo(-10);
        }];
    }
    return self;
}

- (void)setComment:(Comment *)comment{
    
    _comment = comment;
    
    self.name.text = comment.nickname;
    self.date.text = comment.createtime;
    self.comments.text = comment.content;
    
    [self.head sd_setImageWithURL:[NSURL URLWithString:comment.avatar] placeholderImage:[UIImage imageNamed:@"0"]];
    
//    self.head.image = [UIImage imageNamed:@"0"];
    
    int count = (int)comment.url.count;
    
    [self layoutIfNeeded];
    
    //显示图片的宽和高
    float imgW=(Main_WIDTH-100)/3;
    
    if (count == 0) {//当没有照片
        //让所有的图片都隐藏了
        for (int i = 0; i < 9; i++) {
            UIButton *button = (UIButton *)[self viewWithTag:i  + 1000];
            button.hidden = YES;
        }
        //重新给九宫格View布局
        [self.buttonView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.comments.bottom).offset(10);
            make.left.equalTo(10);
            make.width.equalTo(imgW * 3 + 20);
            make.height.equalTo(0);
        }];
        //重新给回复的Label布局(解决了没有图片有评论时间距过大的问题)
        [self.reply remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.comments.bottom).offset(10);
            make.left.equalTo(10);
            make.right.equalTo(-10);
        }];
    }
//        else if (count == 1){
//        //让改显示的图片显示出来
//        UIButton *button = (UIButton *)[self viewWithTag:1000];
//            button.hidden = NO;
//            [button sd_setBackgroundImageWithURL:[NSURL URLWithString:comment.url[0]] forState:UIControlStateNormal];
//        //把其余的图片隐藏了
//        for (int i = count; i < 9; i++) {
//            UIButton *button = (UIButton *)[self viewWithTag:i  + 1000];
//            button.hidden = YES;
//        }
//        
//        button.frame = CGRectMake(0, 0, imgW * 2, imgW * 2);
//        
//        [self.buttonView remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.comments.bottom).offset(10);
//            make.left.equalTo(10);
//            make.width.equalTo(imgW * 3 + 20);
//            make.height.equalTo(imgW * 2);
//        }];
//        
//    }
    else{
        //让改显示的图片显示出来
        for (int i = 0; i < count; i++) {
            UIButton *button = (UIButton *)[self viewWithTag:i + 1000];
            button.hidden = NO;
            [button sd_setImageWithURL:[NSURL URLWithString:comment.url[i]] forState:UIControlStateNormal];
        }
        //把其余的图片隐藏了
        for (int i = count; i < 9; i++) {
            UIButton *button = (UIButton *)[self viewWithTag:i  + 1000];
            button.hidden = YES;
        }
        //重新给九宫格View布局
        [self.buttonView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.comments.bottom).offset(10);
            make.left.equalTo(10);
            make.width.equalTo(imgW * 3 + 20);
            make.height.equalTo(((count - 1) / 3 + 1) * (imgW + 10) - 10);
        }];
        
        //重新给回复的Label布局(还原之前的布局)
        [self.reply remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.buttonView.bottom).offset(10);
            make.left.equalTo(10);
            make.right.equalTo(-10);
        }];

    }


    self.reply.text = [@"发起者返评:\n" stringByAppendingString:comment.toContent];
    
    //cell强制布局
    [self layoutIfNeeded];
    if (comment.toContent.length != 0) {
        if (count != 0) {
            comment.cellHight = CGRectGetMaxY(self.reply.frame) + 10;
        }else{
            comment.cellHight = CGRectGetMaxY(self.reply.frame) + 10;
        }
    }else{
        self.reply.text = nil;
        if (count == 0) {
            comment.cellHight = CGRectGetMaxY(self.buttonView.frame);
        }else{
            comment.cellHight = CGRectGetMaxY(self.buttonView.frame) + 10;
        }
    }
}


- (void)searcimage:(UIButton *)button{
    
    if (_delegate && [_delegate respondsToSelector:@selector(commentsCellsearcimage:)]) {
        [_delegate commentsCellsearcimage:button];
    }
}



@end
