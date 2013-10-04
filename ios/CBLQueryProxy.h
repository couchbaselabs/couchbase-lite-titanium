/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLQueryProxy : TiProxy

+(CBLQueryProxy *)proxyWithDelegate:(CBLQuery *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLQuery * delegate;

@end


@interface CBLLiveQueryProxy : TiProxy

+(CBLLiveQueryProxy *)proxyWithDelegate:(CBLLiveQuery *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLLiveQuery * delegate;

@end


@interface CBLQueryEnumeratorProxy : TiProxy

+(CBLQueryEnumeratorProxy *)proxyWithDelegate:(CBLQueryEnumerator *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLQueryEnumerator * delegate;

@end


@interface CBLQueryRowProxy : TiProxy

+(CBLQueryRowProxy *)proxyWithDelegate:(CBLQueryRow *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLQueryRow * delegate;

@end