@protocol PFAppCellDelegate <NSObject>

-(void)switchValueDidChange:(BOOL)on cell:(UITableViewCell *)cell;

@end

@interface PFAppCell: UITableViewCell

@property (nonatomic, assign) id<PFAppCellDelegate> delegate;
@property (nonatomic, retain) UISwitch *switchView;
@property (nonatomic, retain) UILabel *nameLabel;

@end