import { useState } from 'react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism';
import { Copy, Check } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/app/components/ui/tabs';

interface CodeSnippetsProps {
  isDark: boolean;
}

export default function CodeSnippets({ isDark }: CodeSnippetsProps) {
  const [copiedSnippet, setCopiedSnippet] = useState<string | null>(null);

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedSnippet(id);
    setTimeout(() => setCopiedSnippet(null), 2000);
  };

  const snippets = {
    glassButton: `// Glass Button Component
struct GlassButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}`,

    glassCard: `// Glassmorphism Card
struct GlassCard<Content: View>: View {
    let content: Content
    
    var body: some View {
        content
            .padding()
            .background(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}`,

    colorTokens: `// Design Tokens - Colors
extension Color {
    static let primaryViolet = Color(hex: "#8B5CF6")
    static let accentBlue = Color(hex: "#60A5FA")
    static let neonPurple = Color(hex: "#C084FC")
    
    // Glass Materials
    static let glassSurface = Color.white.opacity(0.1)
    static let glassBorder = Color.white.opacity(0.2)
}

// Gradient Backgrounds
extension LinearGradient {
    static var liquidGlass: LinearGradient {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.3),
                Color.blue.opacity(0.2),
                Color.indigo.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}`,

    microInteractions: `// Micro-interactions
struct PulsingDot: View {
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 8, height: 8)
            .scaleEffect(isPulsing ? 1.5 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// Spring Animation on Tap
.scaleEffect(isPressed ? 0.9 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)`,

    scoreboardGrid: `// Scoreboard Grid Component
struct ScoreboardView: View {
    @State var scores: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 15)
    let targetScore = 500
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(0..<15) { round in
                    HStack(spacing: 8) {
                        Text("R\\(round + 1)")
                            .frame(width: 40)
                            .foregroundColor(.secondary)
                        
                        ForEach(0..<4) { player in
                            TextField("0", value: $scores[round][player], format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .background(.regularMaterial)
    }
}`,

    confetti: `// Confetti Animation View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(piece.position)
                    .onAppear {
                        withAnimation(
                            .linear(duration: piece.duration)
                            .repeatForever(autoreverses: false)
                        ) {
                            piece.position.y += UIScreen.main.bounds.height
                        }
                    }
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    func generateConfetti() {
        let colors: [Color] = [.purple, .blue, .pink, .yellow, .green]
        for i in 0..<50 {
            let piece = ConfettiPiece(
                color: colors.randomElement()!,
                position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: -20),
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 2...4)
            )
            confettiPieces.append(piece)
        }
    }
}`,

    navigation: `// NavigationStack with Glass Toolbar
NavigationStack {
    ScoreboardView()
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .modifier(PulseAnimation())
                    
                    Text("Target: 500")
                        .font(.headline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
}`,

    responsive: `// Responsive Layout (iPhone/iPad)
struct AdaptiveLayout: View {
    @Environment(\\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        if sizeClass == .compact {
            // iPhone Layout
            VStack(spacing: 16) {
                CreateRoomButton()
                JoinRoomButton()
            }
        } else {
            // iPad Layout - Split View
            HStack(spacing: 24) {
                CreateRoomButton()
                    .frame(maxWidth: .infinity)
                JoinRoomButton()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// Container Relative Frame
.containerRelativeFrame(.horizontal) { length, _ in
    sizeClass == .compact ? length : length / 2
}`,
  };

  return (
    <div className="space-y-8">
      <div className={`p-6 rounded-2xl backdrop-blur-xl border ${
        isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
      }`}>
        <h2 className={`text-2xl font-semibold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          SwiftUI Code Snippets
        </h2>
        <p className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
          Ready-to-use SwiftUI code for implementing the design system
        </p>
      </div>

      <Tabs defaultValue="glassButton" className="w-full">
        <TabsList className={`w-full justify-start backdrop-blur-xl border overflow-x-auto ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <TabsTrigger value="glassButton">Glass Button</TabsTrigger>
          <TabsTrigger value="glassCard">Glass Card</TabsTrigger>
          <TabsTrigger value="colorTokens">Color Tokens</TabsTrigger>
          <TabsTrigger value="microInteractions">Animations</TabsTrigger>
          <TabsTrigger value="scoreboardGrid">Scoreboard</TabsTrigger>
          <TabsTrigger value="confetti">Confetti</TabsTrigger>
          <TabsTrigger value="navigation">Navigation</TabsTrigger>
          <TabsTrigger value="responsive">Responsive</TabsTrigger>
        </TabsList>

        {Object.entries(snippets).map(([key, code]) => (
          <TabsContent key={key} value={key} className="mt-6">
            <div className={`relative rounded-2xl overflow-hidden border ${
              isDark ? 'border-white/10' : 'border-black/10'
            }`}>
              <div className={`flex items-center justify-between px-6 py-4 backdrop-blur-xl border-b ${
                isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
              }`}>
                <div className="flex items-center gap-3">
                  <div className="flex gap-2">
                    <div className="w-3 h-3 rounded-full bg-red-500"></div>
                    <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                    <div className="w-3 h-3 rounded-full bg-green-500"></div>
                  </div>
                  <span className={`font-mono text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                    {key}.swift
                  </span>
                </div>
                <button
                  onClick={() => copyToClipboard(code, key)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
                    copiedSnippet === key
                      ? isDark
                        ? 'bg-green-500/20 text-green-400'
                        : 'bg-green-500/30 text-green-600'
                      : isDark
                        ? 'bg-white/10 text-gray-400 hover:bg-white/20 hover:text-white'
                        : 'bg-black/10 text-gray-600 hover:bg-black/20 hover:text-gray-900'
                  }`}
                >
                  {copiedSnippet === key ? (
                    <>
                      <Check className="w-4 h-4" />
                      <span className="text-sm font-medium">Copied!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-4 h-4" />
                      <span className="text-sm font-medium">Copy</span>
                    </>
                  )}
                </button>
              </div>
              <div className="overflow-x-auto">
                <SyntaxHighlighter
                  language="swift"
                  style={vscDarkPlus}
                  customStyle={{
                    margin: 0,
                    padding: '1.5rem',
                    background: isDark ? 'rgba(0, 0, 0, 0.3)' : 'rgba(0, 0, 0, 0.85)',
                    fontSize: '0.875rem',
                    lineHeight: '1.6',
                  }}
                  showLineNumbers={true}
                >
                  {code}
                </SyntaxHighlighter>
              </div>
            </div>
          </TabsContent>
        ))}
      </Tabs>

      {/* Technical Specifications */}
      <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
        isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
      }`}>
        <h3 className={`text-xl font-semibold mb-4 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Technical Requirements
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h4 className={`font-semibold mb-3 ${isDark ? 'text-violet-400' : 'text-violet-600'}`}>
              iOS 18+ Features
            </h4>
            <ul className={`space-y-2 text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              <li>• .containerBackground for glass effects</li>
              <li>• Custom .ultraThinMaterial and .regularMaterial</li>
              <li>• SwiftUI 5 NavigationStack</li>
              <li>• @State driven withAnimation</li>
              <li>• .blur(radius:) modifiers</li>
            </ul>
          </div>
          <div>
            <h4 className={`font-semibold mb-3 ${isDark ? 'text-violet-400' : 'text-violet-600'}`}>
              Accessibility
            </h4>
            <ul className={`space-y-2 text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              <li>• VoiceOver labels on all interactive elements</li>
              <li>• Dynamic Type support (SF Pro Display/Text)</li>
              <li>• High contrast mode compatibility</li>
              <li>• Semantic colors for dark/light mode</li>
              <li>• Minimum touch targets 44x44pt</li>
            </ul>
          </div>
          <div>
            <h4 className={`font-semibold mb-3 ${isDark ? 'text-violet-400' : 'text-violet-600'}`}>
              Responsive Design
            </h4>
            <ul className={`space-y-2 text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              <li>• .containerRelativeFrame for layouts</li>
              <li>• @Environment(\.horizontalSizeClass)</li>
              <li>• iPhone/iPad split-view support</li>
              <li>• Adaptive grid columns</li>
              <li>• Landscape orientation support</li>
            </ul>
          </div>
          <div>
            <h4 className={`font-semibold mb-3 ${isDark ? 'text-violet-400' : 'text-violet-600'}`}>
              Animations
            </h4>
            <ul className={`space-y-2 text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              <li>• .spring() for natural motion</li>
              <li>• .scaleEffect for tap feedback</li>
              <li>• Sync pulse with @State binding</li>
              <li>• Confetti particle system</li>
              <li>• Lottie integration ready</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Xcode Handoff Notes */}
      <div className={`p-8 rounded-2xl backdrop-blur-xl border-2 ${
        isDark 
          ? 'bg-violet-500/10 border-violet-500/30' 
          : 'bg-violet-500/20 border-violet-500/40'
      }`}>
        <h3 className={`text-xl font-semibold mb-4 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          📋 Handoff Checklist for Xcode Implementation
        </h3>
        <div className="space-y-3">
          <div className={`flex items-start gap-3 ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
            <div className="w-6 h-6 rounded-lg bg-green-500 flex items-center justify-center flex-shrink-0 mt-0.5">
              <Check className="w-4 h-4 text-white" />
            </div>
            <div>
              <div className="font-semibold">All design tokens documented</div>
              <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                Colors, spacing, typography, and shadows ready to implement
              </div>
            </div>
          </div>
          <div className={`flex items-start gap-3 ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
            <div className="w-6 h-6 rounded-lg bg-green-500 flex items-center justify-center flex-shrink-0 mt-0.5">
              <Check className="w-4 h-4 text-white" />
            </div>
            <div>
              <div className="font-semibold">Reusable SwiftUI components</div>
              <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                GlassButton, GlassCard, and other modular components
              </div>
            </div>
          </div>
          <div className={`flex items-start gap-3 ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
            <div className="w-6 h-6 rounded-lg bg-green-500 flex items-center justify-center flex-shrink-0 mt-0.5">
              <Check className="w-4 h-4 text-white" />
            </div>
            <div>
              <div className="font-semibold">Screen flows and navigation</div>
              <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                Complete user journey from login to results
              </div>
            </div>
          </div>
          <div className={`flex items-start gap-3 ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
            <div className="w-6 h-6 rounded-lg bg-green-500 flex items-center justify-center flex-shrink-0 mt-0.5">
              <Check className="w-4 h-4 text-white" />
            </div>
            <div>
              <div className="font-semibold">Dark/Light mode variants</div>
              <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                Semantic colors with adaptive appearance
              </div>
            </div>
          </div>
          <div className={`flex items-start gap-3 ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
            <div className="w-6 h-6 rounded-lg bg-green-500 flex items-center justify-center flex-shrink-0 mt-0.5">
              <Check className="w-4 h-4 text-white" />
            </div>
            <div>
              <div className="font-semibold">Animation specifications</div>
              <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                All micro-interactions and timing documented
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
