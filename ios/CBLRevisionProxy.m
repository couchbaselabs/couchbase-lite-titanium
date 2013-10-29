/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLRevisionProxy.h"
#import "CBLDocumentProxy.h"
#import "CBLDatabaseProxy.h"
#import "CBLAttachmentProxy.h"
#import "NSErrorProxy.h"

@implementation CBLRevisionBaseProxy
{
    @protected
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLRevisionBase *)delegate
{
    return [self initWithDelegate:delegate onThread:[NSThread currentThread]];
}

-(id)initWithDelegate:(CBLRevisionBase *)delegate onThread:(NSThread *)thread
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [thread retain];
    }
    
    return self;
}

+(CBLRevisionBaseProxy *)proxyWithDelegate:(CBLRevisionBase *)delegate
{
    return (delegate ? [[CBLRevisionBaseProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLRevisionBaseProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(CBLDocumentProxy *)document
{
    return invoke_block_on_thread(^id{
        return [CBLDocumentProxy proxyWithDelegate:_delegate.document];
    }, _thread);
}

-(CBLDatabaseProxy *)database
{
    return invoke_block_on_thread(^id{
        return [CBLDatabaseProxy proxyWithDelegate:_delegate.database];
    }, _thread);
}

-(NSNumber *)isDeleted
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.isDeleted];
    }, _thread);
}

-(NSString *)revisionId
{
    return invoke_block_on_thread(^id{
        return _delegate.revisionID;
    }, _thread);
}

-(NSDictionary *)properties
{
    return invoke_block_on_thread(^id{
        return _delegate.properties;
    }, _thread);
}

-(NSDictionary *)userProperties
{
    return invoke_block_on_thread(^id{
        return _delegate.userProperties;
    }, _thread);
}

-(id)getProperty:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * key;
        ENSURE_ARG_OR_NIL_AT_INDEX(key, args, 0, NSString);
        
        return [_delegate propertyForKey:key];
    }, _thread);
}

// Same as -propertyForKey:. Enables "[]" access in Xcode 4.4+
//- (id) objectForKeyedSubscript: (NSString*)key;

#pragma mark ATTACHMENTS

-(NSArray *)attachmentNames
{
    return invoke_block_on_thread(^id{
        return _delegate.attachmentNames;
    }, _thread);
}

-(CBLAttachmentProxy *)getAttachment:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        return [CBLAttachmentProxy proxyWithDelegate:[_delegate attachmentNamed:name]];
    }, _thread);
}

-(NSArray *)attachments
{
    return invoke_block_on_thread(^id{
        return [CBLAttachmentProxy proxiesWithDelegates:_delegate.attachments];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


@implementation CBLRevisionProxy

+(CBLRevisionProxy *)proxyWithDelegate:(CBLRevision *)delegate
{
    return (delegate ? [[CBLRevisionProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLRevisionProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(BOOL)isPropertiesLoaded
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:self.delegate.propertiesAreLoaded];
    }, _thread);
}

-(CBLNewRevisionProxy *)createRevision:(id)args
{
    return invoke_block_on_thread(^id{
        return [CBLNewRevisionProxy proxyWithDelegate:self.delegate.newRevision];
    }, _thread);
}

-(CBLRevisionProxy *)putProperties:(id)args
{
    return invoke_block_on_thread(^id{
        NSDictionary * properties;
        ENSURE_ARG_AT_INDEX(properties, args, 0, NSDictionary);
        
        NSError * error;
        id result = [CBLRevisionProxy proxyWithDelegate:[self.delegate putProperties:properties error:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(CBLRevisionProxy *)deleteDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [CBLRevisionProxy proxyWithDelegate:[self.delegate deleteDocument:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(NSArray *)revisionHistory
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [CBLRevisionProxy proxiesWithDelegates:[self.delegate getRevisionHistory:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

@end


@implementation CBLNewRevisionProxy

+(CBLNewRevisionProxy *)proxyWithDelegate:(CBLNewRevision *)delegate
{
    return (delegate ? [[CBLNewRevisionProxy alloc] initWithDelegate:delegate] : nil);
}

+(CBLNewRevisionProxy *)proxyWithDelegate:(CBLNewRevision *)delegate onThread:(NSThread *)thread
{
    return (delegate ? [[CBLNewRevisionProxy alloc] initWithDelegate:delegate onThread:thread] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLNewRevisionProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(void)setIsDeleted:(NSNumber *)isDeleted
{
    void_block_on_thread(^{
        self.delegate.isDeleted = isDeleted.boolValue;
    }, _thread);
}

-(NSMutableDictionary *)properties
{
    return invoke_block_on_thread(^id{
        return self.delegate.properties;
    }, _thread);
}

-(void)setProperties:(NSMutableDictionary *)properties
{
    void_block_on_thread(^{
        self.delegate.properties = properties;
    }, _thread);
}

// Same as -properties:. Enables "[]" access in Xcode 4.4+
//- (void) setObject: (id)object forKeyedSubscript: (NSString*)key;

-(CBLRevisionProxy *)parentRevision
{
    return invoke_block_on_thread(^id{
        return [CBLRevisionProxy proxyWithDelegate:self.delegate.parentRevision];
    }, _thread);
}

-(NSString *)parentRevisionId
{
    return invoke_block_on_thread(^id{
        return self.delegate.parentRevisionID;
    }, _thread);
}

-(CBLRevisionProxy *)save:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [CBLRevisionProxy proxyWithDelegate:[self.delegate save:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(void)addAttachment:(id)args
{
    void_block_on_thread(^{
        CBLAttachmentProxy * attachment;
        ENSURE_ARG_AT_INDEX(attachment, args, 0, CBLAttachmentProxy);
        NSString * name;
        ENSURE_ARG_AT_INDEX(name, args, 1, NSString);
        
        [self.delegate addAttachment:attachment.delegate named:name];
    }, _thread);
}

-(void)removeAttachment:(id)args
{
    void_block_on_thread(^{
        NSString * name;
        ENSURE_ARG_AT_INDEX(name, args, 0, NSString);
        
        [self.delegate removeAttachmentNamed:name];
    }, _thread);
}

@end