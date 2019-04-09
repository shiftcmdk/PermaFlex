#import "../Model/PFProperty.h"

@protocol PFPropertyCellDelegate <NSObject>

-(void)propertyDidChange:(NSString *)property cell:(UITableViewCell *)cell;
-(void)valueDidChange:(NSString *)value cell:(UITableViewCell *)cell;
-(void)segmentedControlDidChange:(int)value cell:(UITableViewCell *)cell;

@end

@interface PFPropertyCell: UITableViewCell

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UITextField *propertyTextField;
@property (nonatomic, retain) UITextField *valueTextField;
@property (nonatomic, retain) UILabel *currentValueLabel;
@property (nonatomic, assign) id<PFPropertyCellDelegate> delegate;

-(void)configureWithProperty:(PFProperty *)prop currentValue:(NSString *)value;

@end