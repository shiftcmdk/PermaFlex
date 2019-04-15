#import "PFFilterManager.h"

@interface PFFilterTableViewController: UITableViewController

@property (nonatomic, retain) UIView *viewToExplore;
@property (nonatomic, retain) PFFilterManager *manager;
@property (nonatomic, copy) NSString *viewClass;

@end