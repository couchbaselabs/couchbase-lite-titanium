/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLManagerProxy : TiProxy

typedef CBLManager * (^CBLManagerDelegateBlock)(void);

+(CBLManagerProxy *)proxyWithDelegateBlock:(CBLManagerDelegateBlock)delegateBlock onNewThread:(BOOL)onNewThread;
+(CBLManagerProxy *)proxyWithDelegate:(CBLManager *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLManager * delegate;

@end
