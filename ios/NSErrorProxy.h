/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"

@interface NSErrorProxy : TiProxy

+(NSErrorProxy *)proxyWithDelegate:(NSError *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) NSError * delegate;

@property (readonly) NSString * domain;
@property (readonly) NSNumber * code;

@property (readonly) NSDictionary * userInfo;

@property (readonly) NSString * localizedDescription;

@property (readonly) NSString * localizedFailureReason;

@property (readonly) NSString * localizedRecoverySuggestion;

@property (readonly) NSArray * localizedRecoveryOptions;

@property (readonly) NSString * helpAnchor;

@end
