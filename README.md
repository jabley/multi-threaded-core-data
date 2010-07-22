# Overview
This is a sample App to demonstrate Core Data multi-threading for safe updates

The application seeds itself with a Core Data entity and then provides a button to run 2 operations. The NSOperations:

* update different fields of the same entity
* take a different amount of time to run (intended to simulate distinct differences caused by networking)
* Attempt to save their changes.

The UI allows one to alter the merge policies that are applied to the NSManagedObjectContext used by the application main thread and by the NSOperations. By looking at the console, you can see which combinate of merge policies will work best for your application.

It seems as though the merge policy on the main thread NSManagedObjectContext has no bearing on the outcome of the merge; only the merge policy on the NSManagedObjectContext that performed some changes has any effect.

For usages where different operations update different fields, it is suggested that NSMergeByPropertyObjectTrumpMergePolicy would be a good option.
For other usages, one would need to balance up the requirements of the application and consider ways of partitioning updates.
