/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLRevisionBaseProxy : TiProxy

+(CBLRevisionBaseProxy *)proxyWithDelegate:(CBLRevisionBase *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLRevisionBase * delegate;

@end


@interface CBLRevisionProxy : CBLRevisionBaseProxy

+(CBLRevisionProxy *)proxyWithDelegate:(CBLRevision *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLRevision * delegate;

@end


@interface CBLNewRevisionProxy : CBLRevisionBaseProxy

+(CBLNewRevisionProxy *)proxyWithDelegate:(CBLNewRevision *)delegate;
+(CBLNewRevisionProxy *)proxyWithDelegate:(CBLNewRevision *)delegate onThread:(NSThread *)thread;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLNewRevision * delegate;

@end