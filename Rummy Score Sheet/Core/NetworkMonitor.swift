//
//  NetworkMonitor.swift
//  Rummy Scorekeeper
//
//  Monitors network reachability status.
//

import Foundation
import Network
import SwiftUI

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    var isConnected: Bool = true
    var isExpensive: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
            }
        }
        monitor.start(queue: queue)
    }
}
