//
//  ViewController.swift
//  Lunar
//
//  Created by zhouqiang on 16/09/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

import Cocoa

struct LunarFile {
    var year:Int
    var data:Data
}

let encoding_big5_HKSCS_1999 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5_HKSCS_1999.rawValue)))
class ViewController: NSViewController {
    let url_prefix = "http://data.weather.gov.hk/gts/time/calendar/text/T"
    let url_sufix  = "c.txt"
    var paths = [LunarFile]()
    let range:CountableClosedRange = 1901...2100
    let path = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).last?.appending("/lunar_hk")
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: path!), withIntermediateDirectories: true, attributes: nil)
        }catch let error {
            print(error)
        }
        for year in range {
            request(year: year)
        }
    }
    func request(year:Int) {
        if !range.contains(year) {
            return
        }
        let url = url_prefix.appendingFormat("%d%@", year,url_sufix)
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                if error != nil {
                    print(error!)
                }else{
                    if let data = data {
                        let model = LunarFile(year: year, data: data)
                        self.addPath(path: model)
                    }
                }
            }).resume()
        }
    }
    func addPath(path:LunarFile) {
        paths.append(path)
        if paths.count == range.count {
            self.write()
        }
    }
    func write() {
        paths.sort { (left, right) -> Bool in
            return left.year < right.year
        }
        paths.forEach { (p:LunarFile) in
            let str = String(data: p.data, encoding: encoding_big5_HKSCS_1999)!
            let data = str.data(using: String.Encoding.utf8)
            let path = self.path?.appending("/\(p.year).txt")
            try? data?.write(to: URL(fileURLWithPath: path!))
        }
    }
}

