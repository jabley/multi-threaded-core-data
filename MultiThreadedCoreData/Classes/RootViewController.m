//
//  RootViewController.m
//  MultiThreadedCoreData
//
//  Created by James Abley on 04/07/2010.
//  Copyright Mobile IQ Ltd 2010. All rights reserved.
//

#import "RootViewController.h"
#import "Person.h"
#import "UpdateFirstNameOperation.h"
#import "UpdateSurnameOperation.h"

enum TableSections {
    TableSectionPersons,
    TableSectionButtons,
    TableSectionMergePolicies
};

@interface RootViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns a string representation of the merge policy.
 */
- (NSString*)mergePolicyName:(id)mergePolicy;

/**
 Resets the merge polices
 */
- (void)resetWasTapped:(id)sender;

- (void)resetPerson:(Person*)person;

/**
 Runs the long-running background operations which will update Core Data.
 */
- (void)runWasTapped:(id)sender;

@end


@implementation RootViewController

@synthesize fetchedResultsController, managedObjectContext;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Core Data threading"];

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    if ([[[self fetchedResultsController] fetchedObjects] count] == 0) {
        Person *person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                                inManagedObjectContext:[self managedObjectContext]];
        [self resetPerson:person];
    }

    taskQueue_ = [[NSOperationQueue alloc] init];
    [taskQueue_ setMaxConcurrentOperationCount:2];

    [self resetWasTapped:nil];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Extension methods
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"firstName"] description];
    [[cell detailTextLabel] setText:[[managedObject valueForKey:@"surname"] description]];
}

- (NSString*)mergePolicyName:(id)mergePolicy {
    if (mergePolicy == NSErrorMergePolicy) {
        return @"NSErrorMergePolicy";
    } else if (mergePolicy == NSMergeByPropertyObjectTrumpMergePolicy) {
        return @"NSMergeByPropertyObjectTrumpMergePolicy";
    } else if (mergePolicy == NSMergeByPropertyStoreTrumpMergePolicy) {
        return @"NSMergeByPropertyStoreTrumpMergePolicy";
    } else if (mergePolicy == NSOverwriteMergePolicy) {
        return @"NSOverwriteMergePolicy";
    } else if (mergePolicy == NSRollbackMergePolicy) {
        return @"NSRollbackMergePolicy";
    } else {
        return [mergePolicy description];
    }
}

- (void)resetWasTapped:(id)sender {
    mainMergePolicy = NSErrorMergePolicy;
    threadedMergePolicy = NSErrorMergePolicy;
    Person *person = [[[self fetchedResultsController] fetchedObjects] objectAtIndex:0];
    [self resetPerson:person];
}

- (void)resetPerson:(Person*)person {
    [person setFirstName:@"George"];
    [person setSurname:@"Washington"];
    [[self managedObjectContext] save:NULL];
}

- (void)runWasTapped:(id)sender {
    NSManagedObjectID *entityID = [[[[self fetchedResultsController] fetchedObjects] objectAtIndex:0] objectID];
    [[self managedObjectContext] setMergePolicy:mainMergePolicy];

    NSOperation *firstName = [[UpdateFirstNameOperation alloc] initWithManagedObjectContext:[self managedObjectContext]
                                                                                mergePolicy:threadedMergePolicy
                                                                                   entityID:entityID];
    NSOperation *surname = [[UpdateSurnameOperation alloc] initWithManagedObjectContext:[self managedObjectContext]
                                                                            mergePolicy:threadedMergePolicy
                                                                               entityID:entityID];

    [taskQueue_ addOperation:firstName];
    [taskQueue_ addOperation:surname];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TableSectionPersons: {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
        case TableSectionButtons: {
            return 1;
        }
        case TableSectionMergePolicies: {
            return 2;
        }
        default: {
            [NSException raise:NSInvalidArgumentException format:@"No such section"];
            return -1;
        }
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch ([indexPath section]) {
        case TableSectionPersons: {
            static NSString *CellIdentifier = @"Cell";

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }

            // Configure the cell.
            Person *person = (Person*) [fetchedResultsController objectAtIndexPath:indexPath];
            [[cell textLabel] setText:[person firstName]];
            [[cell detailTextLabel] setText:[person surname]];

            return cell;
        } case TableSectionButtons: {
            static NSString *CellIdentifier = @"ButtonCell";

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }

            // Add a reset and run button.
            UIButton *reset = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [reset addTarget:self action:@selector(resetWasTapped:) forControlEvents:UIControlEventTouchUpInside];
            [reset setFrame:CGRectMake(7, 7, 100, 30)];
            [reset setTitle:@"Reset" forState:UIControlStateNormal];
            [cell addSubview:reset];

            UIButton *run = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [run addTarget:self action:@selector(runWasTapped:) forControlEvents:UIControlEventTouchUpInside];
            [run setFrame:CGRectMake(200, 7, 100, 30)];
            [run setTitle:@"Run" forState:UIControlStateNormal];
            [cell addSubview:run];

            return cell;
        }
        case TableSectionMergePolicies: {

            static NSString *CellIdentifier = @"MergePolicyCell";

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }

            // Configure the cell.
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

            switch ([indexPath row]) {
                case 0: {
                    [[cell textLabel] setText:[NSString stringWithFormat:@"Main (%@)", [self mergePolicyName:mainMergePolicy]]];
                    break;
                }
                case 1: {
                    [[cell textLabel] setText:[NSString stringWithFormat:@"BG (%@)", [self mergePolicyName:threadedMergePolicy]]];
                    break;
                }
                default:
                    break;
            }

            return cell;
        }
        default: {
            [NSException raise:NSInvalidArgumentException format:@"No such section"];
            return nil;
        }
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case TableSectionPersons: // Don't allow selection of the Person rows
        case TableSectionButtons: // Don't allow selection of the buttons either
            return nil;
        default:
            return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */

    /* Push the view controller responsible for selecting a merge policy. */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }

    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"surname" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:@"Root"];
    [aFetchedResultsController setDelegate:self];

    [self setFetchedResultsController:aFetchedResultsController];
    [aFetchedResultsController release];
    [fetchRequest release];

    [sortDescriptor release];
    [sortDescriptors release];

    return fetchedResultsController;
}


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [fetchedResultsController release];
    [managedObjectContext release];
    [taskQueue_ release];

    [super dealloc];
}

@end
