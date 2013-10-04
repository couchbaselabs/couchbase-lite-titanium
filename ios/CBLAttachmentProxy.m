/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLAttachmentProxy.h"
#import "CBLRevisionProxy.h"
#import "CBLDocumentProxy.h"
#import "TiBlob.h"

@implementation CBLAttachmentProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLAttachment *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLAttachmentProxy *)proxyWithDelegate:(CBLAttachment *)delegate
{
    return (delegate ? [[CBLAttachmentProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLAttachmentProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

// NOTE: Defined in Module
//-(instancetype)initWithContentType:(NSString *)contentType body:(id)body;

-(CBLRevisionBaseProxy *)revision
{
    return invoke_block_on_thread(^id{
        return [CBLRevisionBaseProxy proxyWithDelegate:_delegate.revision];
    }, _thread);
}

-(CBLDocumentProxy *)document
{
    return invoke_block_on_thread(^id{
        return [CBLDocumentProxy proxyWithDelegate:_delegate.document];
    }, _thread);
}

-(NSString *)name
{
    return invoke_block_on_thread(^id{
        return _delegate.name;
    }, _thread);
}

-(NSString *)contentType
{
    return invoke_block_on_thread(^id{
        return _delegate.contentType;
    }, _thread);
}

-(NSNumber *)length
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedLongLong:_delegate.length];
    }, _thread);
}

-(NSDictionary *)metadata
{
    return invoke_block_on_thread(^id{
        return _delegate.metadata;
    }, _thread);
}

-(TiBlob *)body
{
    return invoke_block_on_thread(^id{
        return [[TiBlob alloc] initWithData:_delegate.body mimetype:_delegate.contentType];
    }, _thread);
}

-(NSString *)bodyUrl
{
    return invoke_block_on_thread(^id{
        return _delegate.bodyURL.absoluteString;
    }, _thread);
}

-(CBLRevisionProxy *)update:(id)args
{
    return invoke_block_on_thread(^id{
        TiBlob * body;
        ENSURE_ARG_AT_INDEX(body, args, 0, TiBlob);
        NSString * contentType;
        ENSURE_ARG_AT_INDEX(contentType, args, 1, NSString);
        
        NSError * error;
        id result = [CBLRevisionProxy proxyWithDelegate:[_delegate updateBody:body.data contentType:body.mimeType error:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end
