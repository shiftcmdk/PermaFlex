#import "PFFilterTableViewController.h"
#import "PFFilterManager.h"
#import "Model/PFFilter.h"

@interface FLEXViewExplorerViewController: UIViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldShowDescription;

@property (nonatomic, readonly) UIView *viewToExplore;

@end

%hook FLEXViewExplorerViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self shouldShowDescription] || !self.viewToExplore) {
        return %orig;
    }

    if (section == 0) {
        return %orig + 1;
    }
    return %orig;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.viewToExplore) {
        return %orig;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
            UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
        
            cell.textLabel.text = @"Hidden Variations";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            if ([[PFFilterManager sharedManager] enabled]) {
                cell.textLabel.textColor = [UIColor blackColor];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            return cell;
        }
    }
    return %orig;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.viewToExplore) {
        return %orig;
    }

    if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return NO;
    }
    return %orig;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.viewToExplore) {
        return %orig;
    }

    if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return [[PFFilterManager sharedManager] enabled];
    }
    return %orig;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.viewToExplore) {
        return %orig;
    }

    if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return 44.0;
    }
    return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.viewToExplore) {
        %orig;
    } else if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        if ([[PFFilterManager sharedManager] enabled]) {
            PFFilterTableViewController *ctrl = [[[PFFilterTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            ctrl.viewToExplore = self.viewToExplore;

            [self.navigationController pushViewController:ctrl animated:YES];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        %orig;
    }
}

%end

@interface UIView ()

-(BOOL)pf_shouldHide;
-(void)pf_hideIfNecessary;

@end

%hook UIView

%new
-(BOOL)pf_shouldHide {
    NSString *frameString = [NSString stringWithFormat:@"%@", [self valueForKey:@"frame"]];

    PFFilter *filter = [[PFFilterManager sharedManager] filterForClass:[self class] frame:frameString];

    BOOL shouldHide = NO;

    if (filter) {
        shouldHide = YES;

        for (PFProperty *prop in filter.properties) {
            @try {
                NSString *value = [NSString stringWithFormat:@"%@", [self valueForKeyPath:prop.key]];

                if (prop.equals) {
                    if (![value isEqual:prop.value]) {
                        shouldHide = NO;

                        break;
                    }
                } else {
                    if ([value rangeOfString:prop.value].location == NSNotFound) {
                        shouldHide = NO;

                        break;
                    }
                }
            } @catch (NSException *exception) {
                
            }
        }
    }

    return shouldHide;
}

%new
-(void)pf_hideIfNecessary {
    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.alpha = 0.0;
    }
}

-(void)setBounds:(CGRect)arg1 {
    %orig;

    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.alpha = 0.0;
    }
}

-(void)setCenter:(CGPoint)arg1 {
    %orig;

    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.alpha = 0.0;
    }
}

-(void)setFrame:(CGRect)arg1 {
    %orig;

    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.alpha = 0.0;
    }
}

-(void)layoutSubviews {
    %orig;

    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.alpha = 0.0;
    }
}

-(void)setAlpha:(double)arg1 {
    if ([self pf_shouldHide]) {
        %orig(0.0);
    } else {
        %orig;
    }
}

-(void)setHidden:(BOOL)arg1 {
    %orig;

    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.alpha = 0.0;
    }
}

%end

%ctor {
    BOOL isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];

    if (isSpringBoard) {
        [[PFFilterManager sharedManager] initForSpringBoard];
    }
}
