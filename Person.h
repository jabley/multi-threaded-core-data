//
//  Person.h
//  MultiThreadedCoreData
//
//  Created by James Abley on 04/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Person :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * surname;

@end



