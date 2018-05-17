//
//  HPKURLProtocol.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKURLProtocol.h"
#import "HPKWebViewPool.h"

@implementation HPKURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    
    if ([NSURLProtocol propertyForKey:NSStringFromClass([self class]) inRequest:request]) {
        return NO;
    }

    return ([request.URL.absoluteString caseInsensitiveCompare:kHPKWebViewReuseUrlString] == NSOrderedSame);
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

- (void)startLoading{
    NSData *responseData = [[self _getWebViewReuseLoadString] dataUsingEncoding:NSUTF8StringEncoding];
    [self.client URLProtocol:self didReceiveResponse:[[NSURLResponse alloc]initWithURL:self.request.URL MIMEType:@"text/html" expectedContentLength:responseData.length textEncodingName:@"UTF-8"] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:responseData];
    [self.client URLProtocolDidFinishLoading:self];
}
- (void)stopLoading{
}

#pragma mark -

- (NSString *)_getWebViewReuseLoadString{
    return @"<html><head><meta name=\"viewport\" " @"content=\"initial-scale=1.0,width=device-width,user-scalable=no\"/><title>HybridPageKit-Reuse</title></head></html>";
}

@end
