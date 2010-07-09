//
//  MergePolicySelectionEditor.m
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import "MergePolicySelectionEditor.h"


@implementation MergePolicySelectionEditor

@synthesize keypath = keypath_;
@synthesize mergePoliciesList = mergePoliciesList_;
@synthesize target = target_;

#pragma mark -
#pragma mark Initialization

#pragma mark -
#pragma mark View lifecycle


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [mergePoliciesList_ count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    id mergePolicy = [mergePoliciesList_ objectAtIndex:[indexPath row]];

    [[cell textLabel] setText:[target_ mergePolicyName:mergePolicy]];

    if ([mergePolicy isEqual:[target_ valueForKey:keypath_]]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    id selectedMergePolicy = [mergePoliciesList_ objectAtIndex:[indexPath row]];
    [target_ setValue:selectedMergePolicy forKey:keypath_];
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [keypath_ release];
    [mergePoliciesList_ release];
    [target_ release];

    [super dealloc];
}


@end

