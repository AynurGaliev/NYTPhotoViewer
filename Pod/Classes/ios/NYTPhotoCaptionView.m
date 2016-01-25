//
//  NYTPhotoCaptionView.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/18/15.
//
//

#import "NYTPhotoCaptionView.h"

@interface NYTPhotoCaptionView ()

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *title;

@property (nonatomic) UILabel *label;

@end

@implementation NYTPhotoCaptionView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTitle:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}


#pragma mark - NYTPhotoCaptionView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _title = title;

        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    [self setupTextView];
}

- (void)setupTextView {
    self.label = [[UILabel alloc] init];
    self.label.numberOfLines = 1;
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.textColor = [UIColor whiteColor];
    self.label.translatesAutoresizingMaskIntoConstraints = false;
    self.label.font = [UIFont systemFontOfSize:18.0];
    self.label.text = self.title;

    [self addSubview:self.label];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    
    [self addConstraints:@[heightConstraint, bottomConstraint, leadingConstraint, trailingConstraint]];
}

@end
