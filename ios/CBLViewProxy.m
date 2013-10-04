/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLViewProxy.h"
#import "CBLDatabaseProxy.h"
#import "CBLQueryProxy.h"

#pragma mark CBLMapEmitBlockProxy

@interface CBLMapEmitBlockProxy : TiProxy

+(CBLMapEmitBlockProxy *)proxyWithDelegate:(CBLMapEmitBlock)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLMapEmitBlock delegate;

-(void)emit:(id)args;

@end

@implementation CBLMapEmitBlockProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLMapEmitBlock)delegate
{
    if (self = [super init]) {
        _delegate = [delegate copy];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLMapEmitBlockProxy *)proxyWithDelegate:(CBLMapEmitBlock)delegate
{
    return (delegate ? [[CBLMapEmitBlockProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLMapEmitBlockProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(void)emit:(id)args
{
    void_block_on_thread(^{
        id key;
        ENSURE_ARG_OR_NIL_AT_INDEX(key, args, 0, NSObject);
        id value;
        ENSURE_ARG_OR_NIL_AT_INDEX(value, args, 1, NSObject);
        
        _delegate(key, value);
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


#pragma mark CBLMapBlockProxy

@interface CBLMapBlockProxy : TiProxy

+(CBLMapBlockProxy *)proxyWithDelegate:(CBLMapBlock)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLMapBlock delegate;

@end

@implementation CBLMapBlockProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLMapBlock)delegate
{
    if (self = [super init]) {
        _delegate = [delegate copy];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLMapBlockProxy *)proxyWithDelegate:(CBLMapBlock)delegate
{
    return (delegate ? [[CBLMapBlockProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLMapBlockProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(void)map:(id)args
{
    void_block_on_thread(^{
        NSDictionary * doc;
        ENSURE_ARG_OR_NIL_AT_INDEX(doc, args, 0, NSDictionary);
        CBLMapEmitBlockProxy * emit;
        ENSURE_ARG_OR_NIL_AT_INDEX(emit, args, 1, CBLMapEmitBlockProxy);
        
        _delegate(doc, emit.delegate);
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


#pragma mark CBLReduceBlockProxy

@interface CBLReduceBlockProxy : TiProxy

+(CBLReduceBlockProxy *)proxyWithDelegate:(CBLReduceBlock)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLReduceBlock delegate;

@end

@implementation CBLReduceBlockProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLReduceBlock)delegate
{
    if (self = [super init]) {
        _delegate = [delegate copy];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLReduceBlockProxy *)proxyWithDelegate:(CBLReduceBlock)delegate
{
    return (delegate ? [[CBLReduceBlockProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLReduceBlockProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(void)reduce:(id)args
{
    void_block_on_thread(^{
        NSArray * keys;
        ENSURE_ARG_OR_NIL_AT_INDEX(keys, args, 0, NSArray);
        NSArray * values;
        ENSURE_ARG_OR_NIL_AT_INDEX(values, args, 1, NSArray);
        NSNumber * rereduce;
        ENSURE_ARG_OR_NIL_AT_INDEX(rereduce, args, 2, NSNumber);
        
        _delegate(keys, values, rereduce.boolValue);
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    
    [super dealloc];
}

@end


#pragma mark CBLViewProxy

@implementation CBLViewProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLView *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLViewProxy *)proxyWithDelegate:(CBLView *)delegate
{
    return (delegate ? [[CBLViewProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLViewProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(CBLDatabaseProxy *)database
{
    return invoke_block_on_thread(^id{
        return [CBLDatabaseProxy proxyWithDelegate:_delegate.database];
    }, _thread);
}

-(NSString *)name
{
    return invoke_block_on_thread(^id{
        return _delegate.name;
    }, _thread);
}

-(CBLMapBlockProxy *)map
{
    return invoke_block_on_thread(^id{
        return [CBLMapBlockProxy proxyWithDelegate:_delegate.mapBlock];
    }, _thread);
}

-(CBLReduceBlockProxy *)reduce
{
    return invoke_block_on_thread(^id{
        return [CBLReduceBlockProxy proxyWithDelegate:_delegate.reduceBlock];
    }, _thread);
}

+(CBLMapBlock)mapBlockForCallback:(KrollCallback *)callback inExecutionContext:(id<TiEvaluator>)context {
    CBLMapBlock map = ^(NSDictionary* doc, void (^emit)(id key, id value)) {
        CBLMapEmitBlockProxy * emitProxy = [CBLMapEmitBlockProxy proxyWithDelegate:emit];
        
        [context.krollContext invokeBlockOnThread:^{
            [callback call:[NSArray arrayWithObjects:doc, emitProxy, nil] thisObject:nil];
        }];
    };
    
    return [[map copy] autorelease];
}

+(CBLReduceBlock)reduceBlockForCallback:(KrollCallback *)callback inExecutionContext:(id<TiEvaluator>)context {
    CBLReduceBlock reduce = ^(NSArray* keys, NSArray* values, BOOL rereduce) {
        __block id result;
        
        [context.krollContext invokeBlockOnThread:^{
            result = [callback call:[NSArray arrayWithObjects:keys, values, [NSNumber numberWithBool:rereduce], nil] thisObject:nil];
        }];
        
        return result;
    };
    
    return [[reduce copy] autorelease];
}

-(NSNumber *)setMapAndReduce:(id)args
{
    return invoke_block_on_thread(^id{
        KrollCallback * mapCallback;
        ENSURE_ARG_OR_NIL_AT_INDEX(mapCallback, args, 0, KrollCallback);
        KrollCallback * reduceCallback;
        ENSURE_ARG_OR_NIL_AT_INDEX(reduceCallback, args, 1, KrollCallback);
        NSString * version;
        ENSURE_ARG_OR_NIL_AT_INDEX(version, args, 2, NSString);
        
        CBLMapBlock map = (mapCallback ? [CBLViewProxy mapBlockForCallback:mapCallback inExecutionContext:self.executionContext] : nil);
        CBLReduceBlock reduce = (reduceCallback ? [CBLViewProxy reduceBlockForCallback:reduceCallback inExecutionContext:[self executionContext]] : nil);
        
        return [NSNumber numberWithBool:[_delegate setMapBlock:map reduceBlock:reduce version:version]];
    }, _thread);
}

-(NSNumber *)setMap:(id)args
{
    return invoke_block_on_thread(^id{
        KrollCallback * mapCallback;
        ENSURE_ARG_OR_NIL_AT_INDEX(mapCallback, args, 0, KrollCallback);
        NSString * version;
        ENSURE_ARG_OR_NIL_AT_INDEX(version, args, 1, NSString);
        
        CBLMapBlock map = (mapCallback ? [CBLViewProxy mapBlockForCallback:mapCallback inExecutionContext:self.executionContext] : nil);
        
        return [NSNumber numberWithBool:[_delegate setMapBlock:map version:version]];
    }, _thread);
}

-(NSNumber *)isStale
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.stale];
    }, _thread);
}

-(SInt64)lastSequenceIndexed
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithLongLong:_delegate.lastSequenceIndexed];
    }, _thread);
}

-(void)removeIndex:(id)args
{
    void_block_on_thread(^{
        [_delegate removeIndex];
    }, _thread);
}

-(void)deleteView:(id)args
{
    void_block_on_thread(^{
        [_delegate deleteView];
    }, _thread);
}

-(CBLQueryProxy *)createQuery:(id)args
{
    return invoke_block_on_thread(^id{
        return [CBLQueryProxy proxyWithDelegate:_delegate.query];
    }, _thread);
}

// TODO: Needed?
// Utility function to use in reduce blocks. Totals an array of NSNumbers.
//+ (NSNumber*) totalValues: (NSArray*)values;

// TODO: Needed?
// Registers an object that can compile map/reduce functions from source code.
//+ (void) setCompiler: (id<CBLViewCompiler>)compiler;

// TODO: Needed?
// The registered object, if any, that can compile map/reduce functions from source code.
//+ (id<CBLViewCompiler>) compiler;

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end
