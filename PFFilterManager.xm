#import "PFFilterManager.h"

@interface PFFilterManager ()

@property (nonatomic, retain) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, PFFilter *> *> *filters;
@property (nonatomic, copy) NSString *bundleID;

-(void)save;

@end

@implementation PFFilterManager

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

static void *sbObserver = NULL;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *prefix = @"com.shiftcmdk.permaflex.";

    if ([(NSString *)name hasPrefix:prefix]) {
        NSString *stripped = [(NSString *)name substringFromIndex:[prefix length]];
		NSString *bundleID;
        
        NSScanner *scanner = [NSScanner scannerWithString:stripped];
        [scanner scanUpToString:@" " intoString:&bundleID];
        
        NSString *prefixWithBundleID = [NSString stringWithFormat:@"%@%@ ", prefix, bundleID];
        
        NSString *content = [(NSString *)name substringFromIndex:prefixWithBundleID.length];
        
        NSString *dir = @"/var/mobile/Library/Preferences/PermaFlex/";

        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
        }

        NSString *fileName = [dir stringByAppendingPathComponent:bundleID];

        BOOL saved = [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];

        NSLog(@"[PermaFlex] saving: %i", saved);
    }
}

-(id)initWithBundleID:(NSString *)bundleID {
    if (self = [super init]) {
        self.bundleID = bundleID;

        NSString *fileName = [@"/var/mobile/Library/Preferences/PermaFlex/" stringByAppendingPathComponent:self.bundleID];

        NSData *jsonData = [NSData dataWithContentsOfFile:fileName];

		NSDictionary *viewClassesDict = nil;

        if (jsonData) {
            viewClassesDict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:nil];
        }

        self.filters = [NSMutableDictionary dictionary];

        self.enabled = [viewClassesDict objectForKey:@"enabled"] == nil || [[viewClassesDict objectForKey:@"enabled"] boolValue];

        if (viewClassesDict && self.enabled) {
            for (NSString *key in viewClassesDict) {
                if (![viewClassesDict[key] isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSDictionary *filterDict = viewClassesDict[key];

                NSMutableDictionary *theFilterDict = [NSMutableDictionary dictionary];

                for (NSString *filterKey in filterDict) {
                    PFFilter *filter = [[[PFFilter alloc] initWithClassName:key frame:filterKey] autorelease];

                    if (![filterDict[filterKey] isKindOfClass:[NSArray class]]) {
                        continue;
                    }
                    NSArray *filterProps = filterDict[filterKey];

                    for (NSDictionary *propsDict in filterProps) {
                        NSString *key = [NSString stringWithFormat:@"%@", propsDict[@"key"]];
                        NSString *value = [NSString stringWithFormat:@"%@", propsDict[@"value"]];
                        int equals = [propsDict[@"equals"] intValue];

                        PFProperty *prop = [[[PFProperty alloc] initWithKey:key value:value valid:YES equals:equals] autorelease];

                        [filter.properties addObject:prop];
                    }

                    theFilterDict[filterKey] = filter;
                }

                self.filters[key] = theFilterDict;
            }
        }
        NSLog(@"[PermaFlex] %@ init filters: %@", self.bundleID, self.filters);
    }

    return self;
}

-(void)initForSpringBoard {
    BOOL isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];

    if (isSpringBoard) {
        NSLog(@"[PermaFlex] initForSpringBoard");

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDistributedCenter(),
            &sbObserver,
            notificationCallback,
            NULL,
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );
    }
}

-(void)save {
    NSLog(@"[PermaFlex] save called!!!");
    NSMutableDictionary *classesDict = [NSMutableDictionary dictionary];

    NSMutableArray *keysToRemove = [NSMutableArray array];

    for (NSString *key in self.filters) {
        NSDictionary *filterDict = self.filters[key];

        if (filterDict.count == 0) {
            [keysToRemove addObject:key];
        } else {
            NSMutableDictionary *theFilters = [NSMutableDictionary dictionary];

            for (NSString *filterKey in filterDict) {
                [theFilters addEntriesFromDictionary:[filterDict[filterKey] dictionaryRepresentation]];
            }

            classesDict[key] = theFilters;
        }
    }

    [self.filters removeObjectsForKeys:keysToRemove];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:classesDict options:0 error:nil];
    NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDistributedCenter(), 
        (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.permaflex.%@ %@", self.bundleID, jsonString], 
        NULL, 
        NULL, 
        YES
    );

    NSLog(@"[PermaFlex] save filters: %@", classesDict);
}

-(void)saveFilter:(PFFilter *)filter {
    if (!self.enabled) {
        return;
    }

    NSMutableDictionary *dict = self.filters[filter.className];

    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }

    dict[filter.frame] = filter;

    self.filters[filter.className] = dict;

    [self save];
}

-(void)deleteFilter:(PFFilter *)filter {
    if (!self.enabled) {
        return;
    }

    NSMutableDictionary *dict = self.filters[filter.className];

    [dict removeObjectForKey:filter.frame];

    [self save];
}

-(void)deleteFiltersForClassName:(NSString *)className {
    if (!self.enabled) {
        return;
    }

    [self.filters removeObjectForKey:className];

    [self save];
}

-(NSArray<PFFilter *> *)filtersForClassName:(NSString *)classString {
    if (!self.enabled) {
        return [NSArray array];
    }

    NSMutableDictionary *filterDict = self.filters[classString];

    if (filterDict) {
        return [filterDict allValues];
    }
    return [NSArray array];
}

-(NSArray<PFFilter *> *)filtersForClass:(Class)cls {
    if (!self.enabled) {
        return [NSArray array];
    }

    NSString *classString = NSStringFromClass(cls);

    return [self filtersForClassName:classString];
}

-(PFFilter *)filterForClass:(Class)cls frame:(NSString *)frame {
    if (!self.enabled) {
        return nil;
    }

    NSString *classString = NSStringFromClass(cls);

    PFFilter *possibleFilter = self.filters[classString][frame];

    if (possibleFilter) {
        return possibleFilter;
    }

    return self.filters[classString][@"<any_frame>"];
}

-(BOOL)hasAnyFrameForClass:(Class)cls {
    NSString *classString = NSStringFromClass(cls);

    return self.filters[classString][@"<any_frame>"] != nil;
}

-(NSArray<NSString *> *)allClasses {
    if (!self.enabled) {
        return nil;
    }

    NSMutableArray *classes = [NSMutableArray array];

    for (NSString *key in self.filters) {
        if (self.filters[key].count > 0) {
            [classes addObject:key];
        }
    }

    return [classes sortedArrayUsingSelector:@selector(compare:)];
}

+(instancetype)sharedManager
{
    static PFFilterManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PFFilterManager alloc] initWithBundleID:[NSBundle mainBundle].bundleIdentifier];
    });
    return sharedManager;
}

-(void)dealloc {
    self.filters = nil;

    self.bundleID = nil;

    BOOL isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];

    if (isSpringBoard) {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDistributedCenter(),
            &sbObserver,
            NULL,
            NULL
        );
    }

    [super dealloc];
}

@end