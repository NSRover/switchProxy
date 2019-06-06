//
//  Bash.swift
//  SwitchProxy
//
//  Created by Nirbhay Agarwal on 06/06/2019.
//  Copyright © 2019 Nirbhay Agarwal. All rights reserved.
//

import Cocoa

protocol CommandExecuting {
    func execute(commandName: String) -> String?
    func execute(commandName: String, arguments: [String]) -> String?
}

final class Bash: CommandExecuting {
    
    // MARK: - CommandExecuting
    
    func execute(commandName: String) -> String? {
        return execute(commandName: commandName, arguments: [])
    }
    
    func execute(commandName: String, arguments: [String]) -> String? {
        guard var bashCommand = execute(command: "/bin/bash" , arguments: ["-l", "-c", "which \(commandName)"]) else { return "\(commandName) not found" }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return execute(command: bashCommand, arguments: arguments)
    }
    
    // MARK: Private
    
    private func execute(command: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        return output
    }
}
