//
//  UpdateFirstNameOperation.h
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadedCoreDataOperation.h"

/**
 ThreadedCoreDataOperation that will update the firstName of the specified Person entity.
 */
@interface UpdateFirstNameOperation : ThreadedCoreDataOperation {

  @private
    /**
     The Person entity to be updated.
     */
    NSManagedObjectID *entityID_; // strong

}

/**
 Creates a new ThreadedCoreDataOperation that will update the surname field of the specified Person entity.
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)mainContext
                       mergePolicy:(id)mergePolicy
                          entityID:(NSManagedObjectID*)entityID;

@end
