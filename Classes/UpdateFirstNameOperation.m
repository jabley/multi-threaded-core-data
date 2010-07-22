//
//  UpdateFirstNameOperation.m
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import "UpdateFirstNameOperation.h"
#import "Person.h"

@implementation UpdateFirstNameOperation

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)mainContext
                       mergePolicy:(id)mergePolicy
                          entityID:(NSManagedObjectID *)entityID {

    if (self = [super initWithManagedObjectContext:mainContext mergePolicy:mergePolicy]) {
        entityID_ = [entityID retain];
    }

    return self;
}

- (void) dealloc {
    [entityID_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSOperation
- (void)main {
    Person *person = (Person*) [[self threadedContext] objectWithID:entityID_];
    [person setFirstName:@"Thomas"];

    /* Simulate the operation taking a while to complete. */
    [NSThread sleepForTimeInterval:1.0];

    [self saveThreadedContext];
}

@end
