//
//  SKCashTransaction.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKCashTransaction.h"

@interface SKCashTransaction ()
/// Used internally to properly restructure \c dictionaryValue
@property (nonatomic) BOOL isaRegularTransaction;
@end

@implementation SKCashTransaction

- (id)initWithDictionary:(NSDictionary *)json {
    if (!json.allKeys.count) return nil;
    
    // "last_transaction" is flat, but normal transactions
    // contain "iter_token" and "cash_transaction", so this is the
    // case for normal transactions; we are flattening the JSON
    // to make it easier to deal with in Mantle.
    if (json[@"cash_transaction"])
        json = ({
            _isaRegularTransaction = YES;
            NSMutableDictionary *mjson = @{@"iter_token": json[@"iter_token"]}.mutableCopy;
            [mjson addEntriesFromDictionary:json[@"cash_transaction"]];
            mjson[@"cash_transaction"] = nil;
            mjson;
        });
    
    return [super initWithDictionary:json];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ sender=%@, recipient=%@, message=%@>",
            NSStringFromClass(self.class), self.sender, self.recipient, self.message];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"patination": @"iter_token",
             @"status": @"status",
             @"amount": @"amount",
             @"currencyCode": @"currency_code",
             @"invisible": @"invisible",
             @"lastUpdated": @"last_updated_at",
             @"message": @"message",
             @"rain": @"rain",
             @"identifier": @"transaction_id",
             @"conversationIdentifier": @"conversation_id",
             @"created": @"created_at",
             @"recipient": @"recipient_username",
             @"recipientIdentifier": @"recipient_identifier",
             @"recipientSaveVersion": @"recipient_save_version",
             @"recipientSaved": @"recipient_saved",
             @"recipientViewed": @"recipient_viewed",
             @"sender": @"sender_username",
             @"senderIdentifier": @"sender_id",
             @"senderSaveVersion": @"sender_save_version",
             @"senderSaved": @"sender_saved",
             @"senderViewed": @"sender_viewed"};
}

- (NSDictionary *)dictionaryValue {
    // "last_transaction" is flat and can be used normally
    if (!_isaRegularTransaction) return [super dictionaryValue];
    
    // Regular transactions contain 2 kv pairs:
    // "iter_token" and "cash_transaction"
    NSMutableDictionary *cash_transaction = [super dictionaryValue].mutableCopy;
    NSMutableDictionary *root = @{@"iter_token": cash_transaction[@"iter_token"]}.mutableCopy;
    cash_transaction[@"iter_token"] = nil;
    root[@"cash_transaction"] = cash_transaction.copy;
    return root.copy;
}

MTLTransformPropertyDate(lastUpdated)
MTLTransformPropertyDate(created)

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKCashTransaction class]])
        return [self isEqualToTransaction:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToTransaction:(SKCashTransaction *)transaction {
    return [self.identifier isEqualToString:transaction.identifier] && self.amount == transaction.amount;
}

- (NSComparisonResult)compare:(SKThing<SKPagination> *)thing {
    if ([thing respondsToSelector:@selector(created)])
        return [self.created compare:thing.created];
    return NSOrderedSame;
}

@end