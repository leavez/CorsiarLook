//
//  DeviceService.swift
//  CorsairLook
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import Regex
import RxSwift


class DeviceService {
    
    static let shared = DeviceService()
    let communicator = Communicator()

    
    // MARK:- status

    class Status {
        
        enum PumpMode: String {
            case quiet
            case balanced
            case performance
        }
        
        let bumpMode = Variable<PumpMode>(.quiet)
        let temperature = Variable<Double>(0)
        let rawStatus = Variable<Parser.Status?>(nil)
    }
    
    let status = Status()

    @discardableResult
    func fetchStatus() -> Parser.Status {
        // we just support only one device now
        print("fetch status...")
        return executeCommandAndUpdateState("--device 0")
    }
    
    
    private func updateStatusWithRawValue(_ raw: Parser.Status) {
        status.rawStatus.value = raw
        
        // parse pump mode
        let dict = ["quiet": Status.PumpMode.quiet,
                    "balanced": .balanced,
                    "performance": .performance]
        let mode = dict.first { (key, mode) -> Bool in
            raw.pump.mode.lowercased().contains(key)
            }?.value ?? .quiet
        status.bumpMode.value = mode
        
        // parse temperature
        let tempStr = "[0-9.]+".r!.findFirst(in: raw.temperatures?.first ?? "")?.matched ?? ""
        if let t = Double(tempStr) {
            status.temperature.value = t
        }
    }

    
    
    // MARK:- Action
    
    
    func set(pumpMode: DeviceService.Status.PumpMode) {
        var mode = 3
        switch pumpMode {
        case .quiet: mode = 3
        case .balanced: mode = 4
        case .performance: mode = 5
        }
        executeCommandAndUpdateState("--device 0 --pump mode=\(mode)")
    }
    
    func setLEDToStaticWhite() {
        executeCommandAndUpdateState("--device 0  --led channel=1,mode=0,colors=333333")
    }
    func setLEDToStaticColor(hex:String) {
        executeCommandAndUpdateState("--device 0  --led channel=1,mode=0,colors=\(hex)")
    }
    func setLEDToBreathRainbow() {
        executeCommandAndUpdateState("--device 0  --led channel=1,mode=2")
    }
    
    
    
    // MARK:- private
    
    @discardableResult
    func executeCommandAndUpdateState(_ command: String) -> Parser.Status {
        let output = communicator.command(command)
        let s = Parser.parseStatus(output)
        self.updateStatusWithRawValue(s)
        return s
    }
    
    
    

    
}


struct Parser {
    
    struct Status {
        let vender: String
        let product: String
        let firmware: String
        let temperatures: [String]?
        let fanSpeed: [String]?
        let pump: (
            mode:String,
            speed:String
        )
    }
    
    static func parseStatus(_ output: String) -> Status {
        let output = output + "\n"
        func regexOut(_ re:String, group: Int = 1) -> String {
            return re.r?.findFirst(in: output)?.group(at: group) ?? ""
        }
        let vender = regexOut("Vendor: *(.+)\n")
        let Product = regexOut("Product: *(.+)\n")
        let firmware = regexOut("Firmware: *(.+)\n")
        let temperature = "Temperature( +[0-9]+)?: *(.+)\n".r?.findAll(in: output).map({ $0.group(at: 2) ?? ""})
        let fans = "Fan( ?[0-9]+)?: *[\\w\\W\\n]*?(Speed.+).*\n".r?.findAll(in: output).map { $0.group(at: 2) ?? "" }

        let result = "Pump( ?[0-9]+)?: *.+\\((.+)\\)\n.*?(Speed.+).*\n".r!.findFirst(in: output)
        let mode = result?.group(at: 2) ?? ""
        let speed = result?.group(at: 3) ?? ""
        return Status(vender: vender, product: Product, firmware: firmware, temperatures:temperature, fanSpeed: fans, pump: (mode, speed))
    }
}


class Communicator {
    
    let executeLibPath: String
    
    init() {
        executeLibPath = Bundle.main.path(forResource: "OpenCorsairLink", ofType: nil)!
    }
    
    func command(_ c: String) -> String {
        return Communicator.shell("\(executeLibPath) \(c)")!
    }
    
    
    static func shell(_ command: String) -> String? {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        
        return output
    }
}

/**
 
OpenCorsairLink [options]
Options:
	--help				:Prints this Message
	--version			:Displays version.
	--debug				:Displays enhanced Debug Messages.
	--dump				:Implies --debug. Dump the raw data recieved from the device.
	--machine			:Prints statuses in Machine Readable Format.
	--device <Device Number>	:Select device.

	LED:
	--led channel=N,mode=N,colors=HHHHHH:HHHHHH:HHHHHH,temp=TEMP:TEMP:TEMP
		Channel: <led number> :Selects a led channel to setup. Accepted values are 1 or 2.
		Mode:
			 0 - Static
			 1 - Blink (Only Commander Pro and Asetek Pro)
			 2 - Color Pulse (Only Commander Pro and Asetek Pro)
			 3 - Color Shift (Only Commander Pro and Asetek Pro)
			 4 - Rainbow (Only Commander Pro and Asetek Pro)
			 5 - Temperature (Only Commander Pro, Asetek, and Asetek Pro)
		Colors: <HTML Color Code>			:Define Color for LED.
		Warn: <HTML Color Code>		:Define Color for Warning Temp.
		Temp: <Temperature in Celsius>	:Define Warning Temperature.

	Fan:
	--fan channel=N,mode=N,pwm=PWM,rpm=RPM,temps=TEMP:TEMP:TEMP,speeds=SPEED:SPEED:SPEED
		Channel: <fan number> :Selects a fan to setup. Accepted values are 1, 2, 3 or 4.
		Modes:
			 0 - Fixed PWM (requires to specify the PWM)
			 1 - Fixed RPM (requires to specify the RPM)
			 2 - Default
			 3 - Quiet
			 4 - Balanced
			 5 - Performance
			 6 - Custom Curve
		PWM <PWM Percent> 	:The desired PWM for the selected fan. NOTE: it only works when fan mode is set to Fixed PWM
		RPM <fan RPM> 	:The desired RPM for the selected fan. NOTE: it works only when fan mode is set to Fixed RPM
		For Custom Curves:
			Temps <C>	:Define Celsius Temperatures for Fan.
			Speeds <Percentage>	:Define Values of RPM Percentage for Fan.

	Pump:
	--pump mode=<mode>
		Modes:
			 3 - Quiet
			 5 - Performance

 Without options, OpenCorsairLink will show the status of any detected Corsair Link device.
 
 
 
 */
