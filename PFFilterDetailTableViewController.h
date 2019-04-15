#import "Model/PFFilter.h"
#import "Model/PFFilterDetailDelegate.h"
#import "PFFilterManager.h"

@interface PFFilterDetailTableViewController: UITableViewController

@property (nonatomic, retain) UIView *viewToExplore;
@property (nonatomic, retain) PFFilter *filter;
@property (nonatomic, assign) id<PFFilterDetailDelegate> delegate;
@property (nonatomic, retain) PFFilterManager *manager;

@end