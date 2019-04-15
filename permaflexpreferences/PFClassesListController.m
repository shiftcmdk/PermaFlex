#import "PFClassesListController.h"
#import "../PFFilterManager.h"
#import "../PFFilterTableViewController.h"

@interface PFClassesListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray<NSString *> *classes;
@property (nonatomic, retain) PFFilterManager *manager;

@end

@implementation PFClassesListController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.app.name;

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ClassCell"];

    self.classes = [NSMutableArray array];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PFFilterManager *manager = [[[PFFilterManager alloc] initWithBundleID:self.app.bundleID] autorelease];

        NSArray<NSString *> *tempClasses = [manager allClasses];

        NSMutableArray *indexPaths = [NSMutableArray array];

        for (int i = 0; i < tempClasses.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.manager = manager;
            self.classes = [NSMutableArray arrayWithArray:tempClasses];

            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    });
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.classes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClassCell" forIndexPath:indexPath];

    cell.textLabel.text = [self.classes objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.manager deleteFiltersForClassName:[self.classes objectAtIndex:indexPath.row]];

    [self.classes removeObjectAtIndex:indexPath.row];

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Classes";
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFFilterTableViewController *ctrl = [[[PFFilterTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    ctrl.manager = self.manager;
    ctrl.viewClass = [self.classes objectAtIndex:indexPath.row];

    [self.navigationController pushViewController:ctrl animated:YES];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.app = nil;

    self.manager = nil;

    self.classes = nil;

    [super dealloc];
}

@end