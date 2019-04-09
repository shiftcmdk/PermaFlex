#import "PFFilterTableViewController.h"
#import "PFFilterDetailTableViewController.h"
#import "Model/PFFilter.h"
#import "PFFilterManager.h"

@interface PFFilterTableViewController () <PFFilterDetailDelegate>

@property (nonatomic, retain) NSMutableArray<PFFilter *> *filters;

@end

@implementation PFFilterTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddNewCell"];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FrameIdentifierCell"];

    self.filters = [NSMutableArray arrayWithArray:[[PFFilterManager sharedManager] filtersForClass:[self.viewToExplore class]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.filters.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrameIdentifierCell"];

        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FrameIdentifierCell"] autorelease];
        }

        PFFilter *filter = [self.filters objectAtIndex:indexPath.row];

        cell.textLabel.text = filter.frame;
        if (filter.properties.count == 1) {
            cell.detailTextLabel.text = @"1 additional property";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i additional properties", (int)filter.properties.count];
        }
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddNewCell" forIndexPath:indexPath];

        NSString *frameString = [NSString stringWithFormat:@"%@", [self.viewToExplore valueForKey:@"frame"]];

        cell.textLabel.text = [NSString stringWithFormat:@"Add %@", frameString];
        if ([[PFFilterManager sharedManager] filterForClass:[self.viewToExplore class] frame:frameString]) {
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.textLabel.textColor = self.view.tintColor;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }

        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[PFFilterManager sharedManager] deleteFilter:[self.filters objectAtIndex:indexPath.row]];

        [self.filters removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];

        [self.viewToExplore performSelector:@selector(pf_hideIfNecessary)];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Frame variations";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"Select a row to add additional properties to a frame variation. After deleting a variation a restart of the application may be required.";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PFFilterDetailTableViewController *ctrl = [[[PFFilterDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        ctrl.viewToExplore = self.viewToExplore;
        ctrl.filter = [self.filters objectAtIndex:indexPath.row];
        ctrl.delegate = self;

        UINavigationController *navCon = [[[UINavigationController alloc] initWithRootViewController:ctrl] autorelease];

		//[self.navigationController pushViewController:ctrl animated:YES];
        [self presentViewController:navCon animated:YES completion:nil];
    } else if (indexPath.section == 1) {
        NSString *className = NSStringFromClass([self.viewToExplore class]);

        NSString *frame = [NSString stringWithFormat:@"%@", [self.viewToExplore valueForKey:@"frame"]];

        if (![[PFFilterManager sharedManager] filterForClass:[self.viewToExplore class] frame:frame]) {
            PFFilter *filter = [[[PFFilter alloc] initWithClassName:className frame:frame] autorelease];

            [self.filters addObject:filter];

            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.filters.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

            [[PFFilterManager sharedManager] saveFilter:filter];

            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

            if (cell) {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            [self.viewToExplore performSelector:@selector(pf_hideIfNecessary)];
        }
    }

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)detailDidSave {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)dealloc {
    self.viewToExplore = nil;

    self.filters = nil;

    [super dealloc];
}

@end