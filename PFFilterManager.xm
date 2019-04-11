#import "PFFilterManager.h"

@interface PFFilterManager ()

@property (nonatomic, retain) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, PFFilter *> *> *filters;

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

-(id)init {
    if (self = [super init]) {
        NSString *fileName = [@"/var/mobile/Library/Preferences/PermaFlex/" stringByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];

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
        NSLog(@"[PermaFlex] init filters: %@", self.filters);
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

    for (NSString *key in self.filters) {
        NSDictionary *filterDict = self.filters[key];

        NSMutableDictionary *theFilters = [NSMutableDictionary dictionary];

        for (NSString *filterKey in filterDict) {
            [theFilters addEntriesFromDictionary:[filterDict[filterKey] dictionaryRepresentation]];
        }

        classesDict[key] = theFilters;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:classesDict options:0 error:nil];
    NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];

    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDistributedCenter(), 
        (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.permaflex.%@ %@", bundleID, jsonString], 
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

-(NSArray<PFFilter *> *)filtersForClass:(Class)cls {
    if (!self.enabled) {
        return [NSArray array];
    }

    NSString *classString = NSStringFromClass(cls);

    NSMutableDictionary *filterDict = self.filters[classString];

    if (filterDict) {
        return [filterDict allValues];
    }
    return [NSArray array];
}

-(PFFilter *)filterForClass:(Class)cls frame:(NSString *)frame {
    if (!self.enabled) {
        return nil;
    }

    NSString *classString = NSStringFromClass(cls);

    return self.filters[classString][frame];
}

+(instancetype)sharedManager
{
    static PFFilterManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PFFilterManager alloc] init];
    });
    return sharedManager;
}

-(void)dealloc {
    self.filters = nil;

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