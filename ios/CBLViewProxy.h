/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLViewProxy : TiProxy

+(CBLViewProxy *)proxyWithDelegate:(CBLView *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

+(CBLMapBlock)mapBlockForCallback:(KrollCallback *)callback inExecutionContext:(id<TiEvaluator>)context;
+(CBLReduceBlock)reduceBlockForCallback:(KrollCallback *)callback inExecutionContext:(id<TiEvaluator>)context;

@property (readonly) CBLView * delegate;

@end
