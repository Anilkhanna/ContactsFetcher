//
//  ContactsFetcher.h
//  ContactsFetcher
//
//  Created by Anil Khanna on 11/12/14.
//  Copyright (c) 2014 Anil Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


//Contacts fetching options

enum {
    FetchAllInfo     = 0,
    FetchFirstName   = 1 << 0,
    FetchLastName        = 1 << 1,
    FetchPhoneNumbers  = 1 << 2,
    FetchAddresses    = 1 << 3,
    FetchEmails    = 1 << 4,
};
typedef NSUInteger ContactFetchOptions;

@interface ContactsFetcher : NSObject



// Single contact object represent as below.
/*
 {
    Addresses =     (
                        {
                            City = Hillsborough;
                            CountryCode = us;
                            State = CA;
                            Street = "165 Davis Street";
                            ZIP = 94010;
                        }
                );
    Emails =     (
                    "kate-bell@mac.com",
                    "www.icloud.com"
                );
    FirstName = Kate;
    LastName = Bell;
    Numbers =     (
                    "(555) 564-8583",
                    "(415) 555-3695"
                    );
 }
 */


+ (void)fetchContactsWithOptions:(ContactFetchOptions)options WithCompletion:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure;

/*
 Contacts fecthing with options
 
 */

+ (void)fetchContactsWithOptions:(ContactFetchOptions)options andPredicate:(NSPredicate*)predicate WithCompletion:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure;

/*
 Contacts fecthing with options and predicate
 
 */

@end
