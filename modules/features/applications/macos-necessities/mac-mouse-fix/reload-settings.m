#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

// Mac Mouse Fix 3.0.8 uses this message to reload config.plist in both
// processes. Its file watcher is disabled. Never send secrets over this port.
int main(void) {
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{@"message": @"configFileChanged"}
                                          requiringSecureCoding:NO error:&error];
        if (data == nil) {
            fprintf(stderr, "Mac Mouse Fix: could not encode settings reload.\n");
            return 1;
        }
        for (NSString *name in @[@"com.nuebling.mac-mouse-fix", @"com.nuebling.mac-mouse-fix.helper"]) {
            CFMessagePortRef port = CFMessagePortCreateRemote(NULL, (__bridge CFStringRef)name);
            // A stopped process will read the settings when it next starts.
            if (port == NULL) continue;
            // configFileChanged has no reply, matching the app's own sender.
            SInt32 status = CFMessagePortSendRequest(port, 0x420666, (__bridge CFDataRef)data,
                                                    5, 0, NULL, NULL);
            CFRelease(port);
            if (status != kCFMessagePortSuccess) {
                fprintf(stderr, "Mac Mouse Fix: settings reload failed (%d).\n", (int)status);
                return 1;
            }
        }
    }
    return 0;
}
