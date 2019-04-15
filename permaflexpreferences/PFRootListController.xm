#include "PFRootListController.h"
#import "PFApp.h"
#import "PFAppCell.h"
#import "PFClassesListController.h"

@interface LSApplicationProxy: NSObject

@property (nonatomic,readonly) NSString * bundleIdentifier;
-(id)localizedName;

@end

@interface LSApplicationWorkspace : NSObject

+(id)defaultWorkspace;
-(id)allInstalledApplications;
-(id)allApplications;

@end

@interface UIImage ()

+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;

@end

@interface PFRootListController () <UITableViewDelegate, UITableViewDataSource, PFAppCellDelegate>

@property (nonatomic, retain) NSMutableArray<PFApp *> *apps;
-(NSDictionary *)dictionaryForBundleID:(NSString *)bundleID;

@end

@implementation PFRootListController

-(id)init {
    if (self = [super init]) {
        self.navigationItem.title = @"PermaFlex";
    }

    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[PFAppCell class] forCellReuseIdentifier:@"AppCell"];

    self.navigationItem.title = @"PermaFlex";

    self.apps = [NSMutableArray array];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray<LSApplicationProxy *> *apps = [[%c(LSApplicationWorkspace) defaultWorkspace] allApplications];

        NSMutableDictionary *appsDict = [NSMutableDictionary dictionary];

        for (LSApplicationProxy *app in apps) {
            appsDict[app.bundleIdentifier] = [app localizedName];
        }

        // @"/var/mobile/Library/Preferences/PermaFlex/"
        NSError *error = nil;
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Library/Preferences/PermaFlex/" error:&error];

        NSMutableArray *tempApps = [NSMutableArray array];

        if (!error) {
            for (NSString *fileName in contents) {
                NSString *name = appsDict[fileName];

                BOOL enabled = [[self dictionaryForBundleID:fileName] objectForKey:@"enabled"] == nil || [[[self dictionaryForBundleID:fileName] objectForKey:@"enabled"] boolValue];

                if (name) {
                    PFApp *app = [[[PFApp alloc] initWithBundleID:fileName name:name enabled:enabled] autorelease];

                    [tempApps addObject:app];
                } else if ([fileName isEqual:@"com.apple.springboard"]) {
                    PFApp *app = [[[PFApp alloc] initWithBundleID:fileName name:@"SpringBoard" enabled:enabled] autorelease];

                    [tempApps addObject:app];
                } else if ([fileName hasPrefix:@"com.apple."]) {
                    PFApp *app = [[[PFApp alloc] initWithBundleID:fileName name:fileName enabled:enabled] autorelease];

                    [tempApps addObject:app];
                }
            }
        } else {
            //NSLog(@"%@", error);
        }

        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        tempApps = [NSMutableArray arrayWithArray:[tempApps sortedArrayUsingDescriptors:@[sort]]];

        NSMutableArray *indexPaths = [NSMutableArray array];

        for (int i = 0; i < tempApps.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.apps = tempApps;

            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    });
}

-(NSDictionary *)dictionaryForBundleID:(NSString *)bundleID {
    NSString *fileName = [@"/var/mobile/Library/Preferences/PermaFlex/" stringByAppendingPathComponent:bundleID];

    NSData *jsonData = [NSData dataWithContentsOfFile:fileName];

	NSDictionary *viewClassesDict = nil;

    if (jsonData) {
        viewClassesDict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:nil];
    }

    return viewClassesDict;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFAppCell *cell = (PFAppCell *)[tableView dequeueReusableCellWithIdentifier:@"AppCell" forIndexPath:indexPath];

    PFApp *app = [self.apps objectAtIndex:indexPath.row];

    UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:app.bundleID format:0 scale:[UIScreen mainScreen].scale];

    cell.imageView.image = icon;
    cell.nameLabel.text = app.name;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.switchView.on = app.enabled;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.delegate = self;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFApp *app = [self.apps objectAtIndex:indexPath.row];

        [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Library/Preferences/PermaFlex/" stringByAppendingPathComponent:app.bundleID] error:nil];

        [self.apps removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Modified applications";
    }

    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"Applications that have been modified with PermaFlex will appear here. The configuration files are stored at /var/mobile/Library/Preferences/PermaFlex/.\n\nAfter deleting/enabling/disabling a configuration the application must be restarted for the changes to take effect.";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFClassesListController *ctrl = [[[PFClassesListController alloc] init] autorelease];
    ctrl.app = [self.apps objectAtIndex:indexPath.row];

    [self pushController:ctrl animate:YES];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)switchValueDidChange:(BOOL)on cell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    if (indexPath) {
        PFApp *app = [self.apps objectAtIndex:indexPath.row];

        app.enabled = on;

        NSMutableDictionary *dict = [[[self dictionaryForBundleID:app.bundleID] mutableCopy] autorelease];

        if (dict) {
            [dict setObject:[NSNumber numberWithBool:on] forKey:@"enabled"];

            NSString *fileName = [@"/var/mobile/Library/Preferences/PermaFlex/" stringByAppendingPathComponent:app.bundleID];

            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];

            [jsonString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];

            //NSLog(@"enabledWritten: %i", enabledWritten);
        }
    }
}

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.apps = nil;

    [super dealloc];
}

@end
