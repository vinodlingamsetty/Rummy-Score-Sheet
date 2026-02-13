//
//  OfflineBannerView.swift
//  Rummy Scorekeeper
//
//  Displays a banner when the device is offline.
//

import SwiftUI

struct OfflineBannerView: View {
    private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.caption.bold())
                
                Text("No Internet Connection. Game actions may be limited.")
                    .font(AppTypography.caption1())
            }
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.red.opacity(0.9))
            .cornerRadius(20)
            .padding(.top, 48) // Safe area top padding approximation or dynamic
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: networkMonitor.isConnected)
            .zIndex(999)
        }
    }
}

#Preview {
    OfflineBannerView()
}
