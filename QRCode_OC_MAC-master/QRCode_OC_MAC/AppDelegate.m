//
//  AppDelegate.m
//  QRCode_OC_MAC
//
//  Created by SkyNullCode on 4/24/15.
//  Copyright (c) 2015 SkyNullCode. All rights reserved.
//

#import "AppDelegate.h"
#import "QRCodeGenerator.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSTextField *url_edit;
@property (weak) IBOutlet NSTextField *ver_edit;

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSButton *ios;
@property (weak) IBOutlet NSButton *android;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.url_edit.stringValue = @"http://www.youku.com";
    self.ver_edit.stringValue = @"1.1.1";
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)IOSclick:(id)sender {
    [self.android setState:NSOffState];
}
- (IBAction)Androidclick:(id)sender {
    [self.ios setState:NSOffState];
}

- (IBAction)creatQR:(id)sender {
    //生成版本背景图片
    [self doLoadImageData];
    NSString *name = nil;
    if ([self.ios state] == NSOnState) {
        name = @"IOS";
    }
    else
    {
        name = @"Android";
    }
    
    NSString *info = [[NSString alloc] initWithFormat:@"%@\n版本号为：%@\nURL地址为:%@\n已生成二维码请在桌面查看",name,self.ver_edit.stringValue,self.url_edit.stringValue];
    NSBeginAlertSheet(@"提示", @"确认", @"取消", nil, [[NSApplication sharedApplication] keyWindow], nil, nil, nil, nil, info);
}

-(NSImage *)doLoadImageData
{
    float width = 500;
    float height = 500;
    NSImage *finalImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    
//  obtain images - your sources may vary
    
    NSImage *overImage = nil;
    if ([self.ios state] == NSOnState) {
        overImage = [NSImage imageNamed:@"IOS"];
    }
    else
    {
        overImage = [NSImage imageNamed:@"Android"];
    }
    
    //Android
    
    NSString *url = self.url_edit.stringValue;
    NSImage *mainImage = [QRCodeGenerator qrImageForString:url imageSize:500];//生成二维码
    
    [finalImage lockFocus];
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
    // draw the base image
    [mainImage drawInRect:NSMakeRect(0, 0, width, height)  fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    // draw the overlay image at some offset point
    [overImage drawInRect:NSMakeRect(182, 182, 136, 136)fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    [self CreatVersionPNG:myContext];
    
    [finalImage unlockFocus];

    NSData *finalData = [finalImage TIFFRepresentation];
    NSBitmapImageRep *imageRep =[NSBitmapImageRep imageRepWithData:finalData];
    NSData *data =[imageRep representationUsingType:NSJPEGFileType properties:nil];
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/Desktop/%@.png",NSHomeDirectory(),self.ver_edit.stringValue];
    [data writeToFile:path atomically:YES];
    return nil;
}

-(void) CreatVersionPNG:(CGContextRef) myContext   // 1
{
    CGContextSelectFont (myContext, "Helvetica-Bold",12,kCGEncodingMacRoman);
    CGContextSetTextDrawingMode (myContext, kCGTextFill);
    
    CGContextSetRGBFillColor (myContext,0,0,0,1);
    
    NSString *version = [self.ver_edit stringValue];
    const char *ver_str = [version UTF8String];
    
    NSDictionary *textAtt = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSFont labelFontOfSize:12],
                             NSFontAttributeName,
                             [NSColor disabledControlTextColor],
                             NSForegroundColorAttributeName,
                             nil];
    NSSize size = [version sizeWithAttributes:textAtt];
    
    CGContextShowTextAtPoint (myContext,(500 - size.width)/2,187,ver_str,[version length]); // 10
}

@end
