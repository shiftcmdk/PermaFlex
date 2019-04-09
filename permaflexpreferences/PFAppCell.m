#import "PFAppCell.h"

@implementation PFAppCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.switchView = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        self.switchView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

        [self.contentView addSubview:self.switchView];

        [self.switchView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
        [self.switchView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;

        self.nameLabel = [[[UILabel alloc] init] autorelease];
        //self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLabel.font = [UIFont systemFontOfSize:17.0];

        [self.contentView addSubview:self.nameLabel];

        /*[self.nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
        NSLayoutConstraint *constraint = [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.switchView.leadingAnchor constant:-8.0];
        constraint.priority = 750;
        constraint.active = YES;
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [self.nameLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
        [self.nameLabel.heightAnchor constraintEqualToConstant:44.0].active = YES;*/
    }

    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGFloat labelOriginX = self.imageView ? self.separatorInset.left : self.contentView.layoutMargins.left;

    self.nameLabel.frame = CGRectMake(
        labelOriginX,
        0.0,
        self.contentView.bounds.size.width - labelOriginX - self.switchView.bounds.size.width - 8.0,
        self.contentView.bounds.size.height
    );
}

-(void)switchChanged:(UISwitch *)sender {
    if (self.delegate) {
        [self.delegate switchValueDidChange:sender.isOn cell:self];
    }
}

-(void)dealloc {
    [self.switchView removeFromSuperview];

    self.switchView = nil;

    [self.nameLabel removeFromSuperview];

    self.nameLabel = nil;

    [super dealloc];
}

@end