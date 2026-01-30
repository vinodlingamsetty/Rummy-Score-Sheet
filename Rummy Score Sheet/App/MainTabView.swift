//
//  MainTabView.swift
//  Rummy Scorekeeper
//
//  Custom floating tab bar — Liquid Glass style
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case game
    case friends
    case rules
    case profile

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .game: return "list.bullet.clipboard.fill"
        case .friends: return "person.2.fill"
        case .rules: return "book.fill"
        case .profile: return "person.crop.circle"
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home: HomeView()
        case .game: TabPlaceholderView(title: "Game")
        case .friends: TabPlaceholderView(title: "Friends")
        case .rules: TabPlaceholderView(title: "Rules")
        case .profile: TabPlaceholderView(title: "Profile")
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            selectedTab.content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(AppTheme.glassMaterial, in: Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(AppTheme.glassMaterial)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                }
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppTheme.primaryColor : .white)
                    .shadow(color: isSelected ? AppTheme.primaryColor.opacity(0.5) : .clear, radius: 6)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct TabPlaceholderView: View {
    let title: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()
            Text(title)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MainTabView()
}
