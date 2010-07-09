//
//  ThreadedCoreDataOperation.h
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThreadedCoreDataOperation : NSOperation {

    NSManagedObjectContext *mainContext_;

    NSManagedObjectContext *threadedContext_;

    /**
     The merge policy to use for this Core Data operation.
     */
    id mergePolicy_;
}
/**
 This is the NSManagedObjectContext intended to be used by
 instances of this class for reading and writing to Core Data.
 */
@property (nonatomic, readonly, retain) NSManagedObjectContext *threadedContext;

/**
 Returns the NSManagedObjectContext from the main thread that any updates should be merged into.
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext * mainContext;

/**
 Saves the threaded context, merging the changes into the main context.
 */
- (void)saveThreadedContext;

/**
 Returns a non-nil MIQCoreDataOperation which will merge any changes that this NSOperation makes into the specified
 NSManagedObjectContext.
 @param moc - non-nil NSManagedObjectContext into which any changes will be merged
 @param mergePolicy - non-nil merge policy that the NSManagedObjectContext for this NSOperation will use
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)mainContext mergePolicy:(id)mergePolicy;

@end
