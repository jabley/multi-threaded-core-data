//
//  RootViewController.h
//  MultiThreadedCoreData
//
//  Created by James Abley on 04/07/2010.
//  Copyright Mobile IQ Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;

    /**
     The main NSManagedObjectContext merge policy.
     */
    id mainMergePolicy;

    /**
     The threaded NSManagedObjectContext merge policy.
     */
    id threadedMergePolicy;

    /**
     The operation queue to manage the concurrent tasks.
     */
    NSOperationQueue *taskQueue_;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
