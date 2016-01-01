/*
 * Copyright (c) 2013-2016 by appPlant UG. All rights reserved.
 *
 * @APPPLANT_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apache License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://opensource.org/licenses/Apache-2.0/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPPLANT_LICENSE_HEADER_END@
 */

#import "CDVPlugin+APPAppEvent.h"
#import "AppDelegate+APPAppEvent.h"

@implementation CDVPlugin (APPAppEvent)

#pragma mark -
#pragma mark Life Cycle

/**
 * Its dangerous to override a method from within a category.
 * Instead we will use method swizzling. we set this up in the load call.
 */
+ (void) initialize
{
    if ([NSStringFromClass(self) hasPrefix:@"CDV"])
        return;

    [AppDelegate exchange_methods:@selector(pluginInitialize)
                         swizzled:@selector(swizzled_pluginInitialize)
                            class:self];
}

#pragma mark -
#pragma mark Delegate

/**
 * Registers obervers after plugin was initialized.
 */
- (void) swizzled_pluginInitialize
{
    // This actually calls the original method
    [self swizzled_pluginInitialize];

    [self addObserver:self
             selector:NSSelectorFromString(@"didReceiveLocalNotification:")
                 name:CDVLocalNotification
               object:NULL];

    [self addObserver:self
             selector:NSSelectorFromString(@"didFinishLaunchingWithOptions:")
                 name:UIApplicationDidFinishLaunchingNotification
               object:NULL];

    [self addObserver:self
             selector:NSSelectorFromString(@"didRegisterUserNotificationSettings:")
                 name:UIApplicationRegisterUserNotificationSettings
               object:NULL];
}

#pragma mark -
#pragma mark Core

/**
 * Register an observer if the caller responds to it.
 */
- (void) addObserver:(id)observer
            selector:(SEL)selector
                name:(nullable NSString*)event
              object:(nullable id)object
{
    if (![self respondsToSelector:selector])
        return;

    NSNotificationCenter* center = [NSNotificationCenter
                                    defaultCenter];

    [center addObserver:self
               selector:selector
                   name:event
                 object:nil];
}

@end
