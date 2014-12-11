//
//  ContactsFetcher.m
//  ContactsFetcher
//
//  Created by Anil Khanna on 11/12/14.
//  Copyright (c) 2014 Anil Khanna. All rights reserved.
//

#import "ContactsFetcher.h"

@implementation ContactsFetcher

+ (void)fetchContactsWithOptions:(ContactFetchOptions)options WithCompletion:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure {
    
    if (ABAddressBookRequestAccessWithCompletion) {
        // on iOS 6 , 7 & 8
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        if (err) {
            // handle error
            CFRelease(err);
            return;
        }
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    failure((__bridge NSError *)error);
                } else {
                    readAddressBookContacts(addressBook, options, success);
                }
                CFRelease(addressBook);
            });
        });
    }
}

+ (void)fetchContactsWithOptions:(ContactFetchOptions)options andPredicate:(NSPredicate*)predicate WithCompletion:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure{
    
    [self fetchContactsWithOptions:options WithCompletion:^(NSArray *contacts) {
        success([contacts filteredArrayUsingPredicate:predicate]);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

static void readAddressBookContacts(ABAddressBookRef addressBook, ContactFetchOptions options, void (^completion)(NSArray *contacts)) {
    
    NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    
    NSMutableArray *listOfContacts = [NSMutableArray new];
    NSMutableArray *phNumbers = nil;
    NSMutableArray *emailsArray = nil;
    NSMutableArray *addressArray = nil;
    NSString *firstName = nil;
    NSString *lastName = nil;
    
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        
        NSMutableDictionary *contact = [NSMutableDictionary new];
        
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        
        if (options & FetchFirstName || options == FetchAllInfo) {
            firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            [contact setObject:firstName forKey:@"FirstName"];
        }
        
        if (options & FetchLastName || options == FetchAllInfo) {
            lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
            [contact setObject:lastName forKey:@"LastName"];
        }
        
        
        if (options & FetchAddresses || options == FetchAllInfo) {
            addressArray = [NSMutableArray new];
            
            //FETCHING PHONE ADDRESSES
            ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonAddressProperty);
            CFIndex numberOfAddress = ABMultiValueGetCount(addresses);
            for (CFIndex i = 0; i < numberOfAddress; i++) {
                NSDictionary *address = CFBridgingRelease(ABMultiValueCopyValueAtIndex(addresses, i));
                // NSLog(@"  phone:%@", address);
                [addressArray addObject:address];
            }
            CFRelease(addresses);
            
            [contact setObject:addressArray forKey:@"Addresses"];
            
        }
        if (options & FetchPhoneNumbers || options == FetchAllInfo) {
            phNumbers = [NSMutableArray new];
            
            //FETCHING PHONE NUMBERS
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
            for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
                NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
                // NSLog(@"  phone:%@", phoneNumber);
                [phNumbers addObject:phoneNumber];
            }
            CFRelease(phoneNumbers);
            
            [contact setObject:phNumbers forKey:@"Numbers"];
            
        }
        if (options & FetchEmails || options == FetchAllInfo) {
            emailsArray = [NSMutableArray new];
            
            //FETCHING PHONE EMAILS
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            CFIndex numberOfEmails = ABMultiValueGetCount(emails);
            for (CFIndex i = 0; i < numberOfEmails; i++) {
                NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, i));
                // NSLog(@"  phone:%@", email);
                [emailsArray addObject:email];
            }
            CFRelease(emails);
            [contact setObject:emailsArray forKey:@"Emails"];
            
        }
        
        [listOfContacts addObject:[contact copy]];
        phNumbers = nil;
        emailsArray = nil;
        addressArray = nil;
        contact = nil;
    }
    
    completion(listOfContacts);
}


@end
