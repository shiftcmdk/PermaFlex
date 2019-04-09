#import "Model/PFFilter.h"
#import "Model/PFFilterDetailDelegate.h"

@interface PFFilterDetailTableViewController: UITableViewController

@property (nonatomic, retain) UIView *viewToExplore;
@property (nonatomic, retain) PFFilter *filter;
@property (nonatomic, assign) id<PFFilterDetailDelegate> delegate;

@end