//
//  DeviceService.swift
//  CorsairLook
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation



class DeviceService {
    
    static let shared = DeviceService()
    
    class Temperture {
        
        func getStatue() -> Int {
            return 12
        }
    }
    
    let temperture = Temperture()
    
    
}


private class Communicator {
    
    func command(_ c: String) -> String {
        
    }
    
    private func shell(launchPath: String, arguments: [String]) -> String? {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        
        return output
    }
}

