//
//  RulesView.swift
//  Rummy Scorekeeper
//
//  Rules and game guide
//

import SwiftUI

struct RulesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing._6) {
                        // Header
                        headerSection
                        
                        // Deck Guide
                        deckGuideSection
                        
                        // Basic Rules
                        basicRulesSection
                        
                        // Scoring System
                        scoringSystemSection
                        
                        // Point System
                        pointSystemSection
                    }
                    .padding(.horizontal, AppSpacing._4)
                    .padding(.top, AppSpacing._4)
                    .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
                }
            }
            .navigationTitle("Rules")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing._3) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.primaryColor)
            
            Text("Indian Rummy")
                .font(AppTypography.title1())
                .foregroundStyle(.primary)
            
            Text("Learn the rules and scoring system")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._5)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
    }
    
    // MARK: - Deck Guide Section
    
    private var deckGuideSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            sectionHeader(icon: "suit.club.fill", title: "Deck Guide")
            
            VStack(spacing: AppSpacing._3) {
                deckGuideRow(players: "2 Players", decks: "1-2 Decks")
                divider
                deckGuideRow(players: "2-6 Players", decks: "2 Decks")
                divider
                deckGuideRow(players: "7+ Players", decks: "3 Decks")
            }
            .padding(AppSpacing._4)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }
    
    private func deckGuideRow(players: String, decks: String) -> some View {
        HStack {
            HStack(spacing: AppSpacing._2) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.primaryColor)
                Text(players)
                    .font(AppTypography.body())
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text(decks)
                .font(AppTypography.headline())
                .foregroundStyle(AppTheme.primaryColor)
        }
    }
    
    // MARK: - Basic Rules Section
    
    private var basicRulesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            sectionHeader(icon: "list.bullet.clipboard.fill", title: "How to Play")
            
            VStack(spacing: AppSpacing._3) {
                ruleItem(
                    number: "1",
                    title: "Objective",
                    description: "Form valid sets and sequences with your cards. The first player to go out wins the round."
                )
                
                divider
                
                ruleItem(
                    number: "2",
                    title: "Game Flow",
                    description: "Each player draws a card, then discards one. Continue until someone declares by forming valid combinations."
                )
                
                divider
                
                ruleItem(
                    number: "3",
                    title: "Scoring",
                    description: "When a player declares, all other players count their unmatched cards. Each card has a point value."
                )
                
                divider
                
                ruleItem(
                    number: "4",
                    title: "Elimination",
                    description: "If your total score reaches the point limit, you're eliminated. The last player standing wins!"
                )
            }
            .padding(AppSpacing._4)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }
    
    private func ruleItem(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing._3) {
            // Number Badge
            Text(number)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(AppTheme.primaryColor, in: Circle())
            
            VStack(alignment: .leading, spacing: AppSpacing._1) {
                Text(title)
                    .font(AppTypography.headline())
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(AppTypography.body())
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Scoring System Section
    
    private var scoringSystemSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            sectionHeader(icon: "number.circle.fill", title: "Card Values")
            
            VStack(spacing: AppSpacing._3) {
                cardValueRow(cards: "A, 2, 3, 4, 5, 6, 7, 8, 9", value: "Face Value")
                divider
                cardValueRow(cards: "10, J, Q, K", value: "10 Points Each")
                divider
                cardValueRow(cards: "Joker", value: "0 Points")
            }
            .padding(AppSpacing._4)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            
            InfoBox(
                icon: "lightbulb.fill",
                text: "Tip: Low-value cards are safer to hold. Try to get rid of face cards early!"
            )
        }
    }
    
    private func cardValueRow(cards: String, value: String) -> some View {
        HStack {
            Text(cards)
                .font(AppTypography.body())
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.headline())
                .foregroundStyle(AppTheme.primaryColor)
        }
    }
    
    // MARK: - Point System Section
    
    private var pointSystemSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            sectionHeader(icon: "dollarsign.circle.fill", title: "Point System")
            
            VStack(alignment: .leading, spacing: AppSpacing._3) {
                InfoBox(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Set a Point Limit (e.g., 101, 201, 350 points). Players are eliminated when they reach this limit.",
                    color: AppTheme.primaryColor
                )
                
                InfoBox(
                    icon: "dollarsign.square.fill",
                    text: "Optionally, assign a Point Value (e.g., $0.10 per point). This determines monetary settlements.",
                    color: Color.orange
                )
                
                InfoBox(
                    icon: "trophy.fill",
                    text: "The winner receives payment from each eliminated player based on their final score difference.",
                    color: AppTheme.positiveColor
                )
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: AppSpacing._2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.primaryColor)
            
            Text(title.uppercased())
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, AppSpacing._3)
    }
    
    private var divider: some View {
        Divider()
            .background(Color.white.opacity(0.1))
    }
}

// MARK: - Info Box Component

private struct InfoBox: View {
    let icon: String
    let text: String
    var color: Color = AppTheme.primaryColor
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing._3) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(text)
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing._4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    RulesView()
        .preferredColorScheme(.dark)
}
