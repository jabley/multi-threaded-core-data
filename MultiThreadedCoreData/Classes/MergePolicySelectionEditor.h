//
//  MergePolicySelectionEditor.h
//  MultiThreadedCoreData
//
//  Created by James Abley on 09/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MergePolicySelectionEditor : UITableViewController {

  @private

    /**
     The keypath of the target object.
     */
    NSString *keypath_;

    /**
     The merge policies that can be selected.
     */
    NSArray *mergePoliciesList_;

    /**
     The target object being modified.
     */
    NSObject *target_;

}

@property (nonatomic, copy) NSString *keypath;

@property (nonatomic, retain) NSArray *mergePoliciesList;

@property (nonatomic, retain) NSObject *target;

@end
