//
//  MEDebug.swift
//  RecogApp
//
//  Created by Mitsuharu Emoto on 2014/07/24.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

import UIKit

// How to specify DEBUG and RELEASE flags in Xcode with Swift or Objective-C – Kitefaster <http://kitefaster.com/2016/01/23/how-to-specify-debug-and-release-flags-in-xcode-with-swift/>

/*
 How to specify DEBUG and RELEASE flags in Xcode with Swift or Objective-C – Kitefaster
 http://kitefaster.com/2016/01/23/how-to-specify-debug-and-release-flags-in-xcode-with-swift/
 */

private func meoDebugPrint<T>(contents: T, function: String = #function, line: Int = #line)
{
    if MEODebug.isDebug() == false{
        return;
    }

    let format:DateFormatter = DateFormatter();
    format.dateFormat = "yyyy/MM/dd HH:mm:ss";
    format.timeZone = NSTimeZone.system;
    format.locale = NSLocale.system;
    
    let date:NSDate = NSDate();
    let dateStr = format.string(from: date as Date)
    
    var isVoid:Bool = false;
    if contents is String{
        let str:String = contents as! String;
        if str.characters.count == 0{
            isVoid = true;
        }
    }

    if isVoid == true {
        print("[\(dateStr) \(function) : \(line)]")
    }else{
        print("[\(dateStr) \(function) : \(line)] \(contents)")
    }
}

public func DLOG(function: String = #function, line: Int = #line)
{
    meoDebugPrint(contents:"", function:function, line:line);
}

public func LOG(function: String = #function, line: Int = #line)
{
    meoDebugPrint(contents:"", function:function, line:line);
}

public func DLOG<T>(_ contents: T, function: String = #function, line: Int = #line)
{
    meoDebugPrint(contents:contents, function:function, line:line);
}

public func LOG<T>(_ contents: T, function: String = #function, line: Int = #line)
{
    meoDebugPrint(contents:contents, function:function, line:line);
}

public class MEODebug: NSObject
{
    var debug:Bool!;
    
    override public init() {
        super.init();
        self.debug = false;
    }
    
    deinit{
    }
    
    private class func defaultDebug() -> MEODebug{
        struct Static {
            static let instance: MEODebug = MEODebug()
        }
        let obj:MEODebug = Static.instance
        return obj
    }
    
    public class func isDebug() -> Bool{
        let dbg:MEODebug = MEODebug.defaultDebug();
        var rtn:Bool = dbg.debug
        
        #if DEBUG
        rtn = true
        #endif
        
        return rtn;
    }
    
    public class func setDebug(debug:Bool){
        let dbg:MEODebug = MEODebug.defaultDebug();
        dbg.debug = debug;
    }
}
