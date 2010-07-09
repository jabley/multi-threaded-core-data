//
//  ThreadedCoreDataOperation.m
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import "ThreadedCoreDataOperation.h"

/**
 Category for private API of this class.
 */
@interface ThreadedCoreDataOperation(PrivateMethods)

/**
 Selector called when the threaded context is saved (registered and unregistered for notifications) which is responsible
 for merging the threaded context changes into the main thread context.
 @param notification - notification
 */
- (void)mergeThreadedContextChangesIntoMainContext:(NSNotification *)notification;

@end

@implementation ThreadedCoreDataOperation

@synthesize mainContext = mainContext_;
@synthesize threadedContext = threadedContext_;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)mainContext mergePolicy:(id)mergePolicy {
    if (self = [super init]) {
        mainContext_ = [mainContext retain];
        mergePolicy_ = [mergePolicy retain];
    }

    return self;
}

- (void) dealloc {
    [mainContext_ release];
    [threadedContext_ release];
    [mergePolicy_ release];

    [super dealloc];
}

#pragma mark -
#pragma mark ThreadedCoreDataOperation
- (NSManagedObjectContext*)threadedContext {
    if (!threadedContext_) {
        threadedContext_ = [[NSManagedObjectContext alloc] init];
        [threadedContext_ setPersistentStoreCoordinator:[mainContext_ persistentStoreCoordinator]];
        [threadedContext_ setMergePolicy:mergePolicy_];
    }

    return [[threadedContext_ retain] autorelease];
}

- (void)saveThreadedContext {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    [defaultCenter addObserver:self
                      selector:@selector(mergeThreadedContextChangesIntoMainContext:)
                          name:NSManagedObjectContextDidSaveNotification
                        object:self.threadedContext];

    if ([[self threadedContext] hasChanges]) {

        NSError *error;

        BOOL contextDidSave = [[self threadedContext] save:&error];

        if (!contextDidSave) {

            // If the context failed to save, log out as many details as possible.
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);

            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];

            if (detailedErrors != nil && [detailedErrors count] > 0) {

                for (NSError* detailedError in detailedErrors) {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            } else {
                NSLog(@"  %@", [error userInfo]);
            }
        }
    }

    [defaultCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[self threadedContext]];
}

#pragma mark -
#pragma mark PrivateMethods
- (void)mergeThreadedContextChangesIntoMainContext:(NSNotification *)notification {
    NSLog(@"%@:%@ merging changes", self, NSStringFromSelector(_cmd));
	[mainContext_ performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                   withObject:notification
                                waitUntilDone:YES];
}


@end
