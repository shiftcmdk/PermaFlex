#import "PFFilterDetailTableViewController.h"
#import "Cells/PFPropertyCell.h"
#import "Model/PFProperty.h"
#include <objc/runtime.h>

@interface PFFilterDetailTableViewController () <PFPropertyCellDelegate>

-(void)updateCell:(UITableViewCell *)cell;
@property (nonatomic, retain) NSMutableArray *currentValues;
@property (nonatomic, retain) NSMutableArray<PFProperty *> *properties;

@end

@implementation PFFilterDetailTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddNewCell"];
    [self.tableView registerClass:[PFPropertyCell class] forCellReuseIdentifier:@"PropertyCell"];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)] autorelease];

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.currentValues = [NSMutableArray array];

    self.properties = [NSMutableArray array];

    for (PFProperty *prop in self.filter.properties) {
        // -(id)initWithKey:(NSString *)key value:(NSString *)value valid:(BOOL)valid equals:(BOOL)equals;
        PFProperty *newProp = [[[PFProperty alloc] initWithKey:prop.key value:prop.value valid:prop.valid equals:prop.equals] autorelease];

        [self.properties addObject:newProp];

        if (self.viewToExplore) {
            @try {
                NSString *value = [NSString stringWithFormat:@"%@", [self.viewToExplore valueForKeyPath:newProp.key]];
                
                [self.currentValues addObject:value];
            } @catch (NSException *exception) {
                [self.currentValues addObject:@""];
            }
        } else {
            [self.currentValues addObject:@""];
        }
    }
}

-(void)doneButtonTapped:(UIBarButtonItem *)sender {
    NSMutableArray *validProps = [NSMutableArray array];

    for (PFProperty *prop in self.properties) {
        if (prop.valid) {
            [validProps addObject:prop];
        }
    }

    self.filter.properties = validProps;

    [self.manager saveFilter:self.filter];

    if (self.delegate) {
        [self.delegate detailDidSave];
    }

    [self.view endEditing:YES];

    [self.viewToExplore performSelector:@selector(pf_hideIfNecessary)];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewToExplore ? self.properties.count + 1 : self.properties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.properties.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddNewCell" forIndexPath:indexPath];

        cell.textLabel.text = @"Add new property/ivar";
        cell.textLabel.textColor = self.view.tintColor;

        return cell;
    } else {
        PFPropertyCell *cell = (PFPropertyCell *)[tableView dequeueReusableCellWithIdentifier:@"PropertyCell" forIndexPath:indexPath];

        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.propertyTextField.userInteractionEnabled = self.viewToExplore != nil;

        PFProperty *prop = [self.properties objectAtIndex:indexPath.row];
        NSString *currentValue = [self.currentValues objectAtIndex:indexPath.row];

        [cell configureWithProperty:prop currentValue:currentValue];

        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Additional properties/ivars";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"PermaFlex will only save properties/ivars that are valid. After deleting a property/ivar a restart of the application may be required.";
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.row < self.properties.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.properties removeObjectAtIndex:indexPath.row];
        [self.currentValues removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        [self.viewToExplore performSelector:@selector(pf_hideIfNecessary)];
    }
}

-(void)updateCell:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[PFPropertyCell class]]) {
        PFPropertyCell *theCell = (PFPropertyCell *)cell;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:theCell];

        // -(void)configureWithProperty:(PFProperty *)prop currentValue:(NSString *)value;
        PFProperty *prop = [self.properties objectAtIndex:indexPath.row];

        prop.key = theCell.propertyTextField.text;
        prop.value = theCell.valueTextField.text;
        prop.equals = theCell.segmentedControl.selectedSegmentIndex == 0;

        NSString *currentValue;

        if (self.viewToExplore) {
            @try {
            currentValue = [NSString stringWithFormat:@"%@", [self.viewToExplore valueForKeyPath:theCell.propertyTextField.text]];

                prop.valid = YES;
            } @catch (NSException *exception) {
                currentValue = @"";

                prop.valid = NO;
            }
        } else {
            currentValue = @"";
            prop.valid = YES;
        }

        [self.currentValues replaceObjectAtIndex:indexPath.row withObject:currentValue];

        [theCell configureWithProperty:prop currentValue:currentValue];
    }

    [UIView performWithoutAnimation:^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

-(void)propertyDidChange:(NSString *)property cell:(UITableViewCell *)cell {
    [self updateCell:cell];
}

-(void)valueDidChange:(NSString *)value cell:(UITableViewCell *)cell {
    [self updateCell:cell];
}

-(void)segmentedControlDidChange:(int)value cell:(UITableViewCell *)cell {
    PFPropertyCell *theCell = (PFPropertyCell *)cell;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:theCell];

    PFProperty *prop = [self.properties objectAtIndex:indexPath.row];
    prop.equals = value == 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == self.properties.count) {
        [self.properties addObject:[[[PFProperty alloc] initWithKey:@"" value:@"" valid:NO equals:YES] autorelease]];
        [self.currentValues addObject:@""];

        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.properties.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)dealloc {
    self.viewToExplore = nil;
    self.properties = nil;
    self.filter = nil;
    self.manager = nil;
    self.currentValues = nil;

    [super dealloc];
}

@end