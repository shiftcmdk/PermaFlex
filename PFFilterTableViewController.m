#import "PFFilterTableViewController.h"
#import "PFFilterDetailTableViewController.h"
#import "Model/PFFilter.h"

@interface PFFilterTableViewController () <PFFilterDetailDelegate>

@property (nonatomic, retain) NSMutableArray<PFFilter *> *filters;

@end

@implementation PFFilterTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddNewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddAnyFrameCell"];

    if (self.viewToExplore) {
        self.filters = [NSMutableArray arrayWithArray:[self.manager filtersForClass:[self.viewToExplore class]]];
    } else {
        self.filters = [NSMutableArray arrayWithArray:[self.manager filtersForClassName:self.viewClass]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.viewToExplore) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.filters.count;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrameIdentifierCell"];

        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FrameIdentifierCell"] autorelease];
        }

        PFFilter *filter = [self.filters objectAtIndex:indexPath.row];

        if ([filter.frame isEqual:@"<any_frame>"]) {
            cell.textLabel.text = @"Any Frame";
        } else {
            cell.textLabel.text = filter.frame;
        }

        if (filter.properties.count == 1) {
            cell.detailTextLabel.text = @"1 additional property";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i additional properties", (int)filter.properties.count];
        }

        return cell;
    } else {
        UITableViewCell *cell;

        NSString *frameString = [NSString stringWithFormat:@"%@", [self.viewToExplore valueForKey:@"frame"]];

        PFFilter *existingFilter = [self.manager filterForClass:[self.viewToExplore class] frame:frameString];

        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddNewCell" forIndexPath:indexPath];

            cell.textLabel.text = [NSString stringWithFormat:@"Add %@", frameString];

            BOOL createFrameSpecific = !existingFilter || [existingFilter.frame isEqual:@"<any_frame>"];

            if (createFrameSpecific) {
                cell.textLabel.textColor = self.view.tintColor;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddAnyFrameCell" forIndexPath:indexPath];

            cell.textLabel.text = @"Add Any Frame";

            BOOL createAnyFrame = !existingFilter || ![self.manager hasAnyFrameForClass:[self.viewToExplore class]];
            
            if (createAnyFrame) {
                cell.textLabel.textColor = self.view.tintColor;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }

        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.manager deleteFilter:[self.filters objectAtIndex:indexPath.row]];

        [self.filters removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        if (self.viewToExplore) {
            [tableView reloadRowsAtIndexPaths:@[
                [NSIndexPath indexPathForRow:0 inSection:1], 
                [NSIndexPath indexPathForRow:1 inSection:1]
            ] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.viewToExplore performSelector:@selector(pf_hideIfNecessary)];
        }
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
    } else if (section == 1) {
        return @"Frame specific variations take precedence over the \"Any Frame\" variation.";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PFFilterDetailTableViewController *ctrl = [[[PFFilterDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        ctrl.viewToExplore = self.viewToExplore;
        ctrl.filter = [self.filters objectAtIndex:indexPath.row];
        ctrl.delegate = self;
        ctrl.manager = self.manager;

        UINavigationController *navCon = [[[UINavigationController alloc] initWithRootViewController:ctrl] autorelease];

		//[self.navigationController pushViewController:ctrl animated:YES];
        [self presentViewController:navCon animated:YES completion:nil];
    } else if (indexPath.section == 1) {
        NSString *className = NSStringFromClass([self.viewToExplore class]);

        NSString *frame;

        if (indexPath.row == 0) {
            frame = [NSString stringWithFormat:@"%@", [self.viewToExplore valueForKey:@"frame"]];
        } else {
            frame = @"<any_frame>";
        }

        PFFilter *existingFilter = [self.manager filterForClass:[self.viewToExplore class] frame:frame];

        BOOL createFrameSpecific = (!existingFilter || [existingFilter.frame isEqual:@"<any_frame>"]) && indexPath.row == 0;
        BOOL createAnyFrame = (!existingFilter || ![self.manager hasAnyFrameForClass:[self.viewToExplore class]]) && indexPath.row == 1;

        if (createFrameSpecific || createAnyFrame) {
            PFFilter *filter = [[[PFFilter alloc] initWithClassName:className frame:frame] autorelease];

            [self.filters addObject:filter];

            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.filters.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.manager saveFilter:filter];

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

    self.manager = nil;

    self.viewClass = nil;

    [super dealloc];
}

@end