//
//  TitaniumUtils.h
//  CouchbaseLiteTitanium
//
//  Created by Wayne Carter on 9/28/13.
//
//

#import <CouchbaseLite/CouchbaseLite.h>
#import "TiProxy.h"

@interface TitaniumUtils : CBLModel

+ (void)throwError:(NSError *)error withProxy:(TiProxy *)proxy;

@end
