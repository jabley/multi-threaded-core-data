//
//  UpdateSurnameOperation.m
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import "UpdateSurnameOperation.h"
#import "Person.h"

@implementation UpdateSurnameOperation

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
    [person setSurname:@"Nixon"];

    /* Simulate the operation taking a while to complete. */
    [NSThread sleepForTimeInterval:2.0];

    [self saveThreadedContext];
}

@end
