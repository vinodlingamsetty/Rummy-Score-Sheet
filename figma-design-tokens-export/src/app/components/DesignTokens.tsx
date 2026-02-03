import { Copy } from 'lucide-react';
import { motion } from 'motion/react';

interface DesignTokensProps {
  isDark: boolean;
}

export default function DesignTokens({ isDark }: DesignTokensProps) {
  const colors = [
    { name: 'Primary Violet', light: '#7C3AED', dark: '#8B5CF6', var: 'systemIndigo' },
    { name: 'Accent Blue', light: '#3B82F6', dark: '#60A5FA', var: 'systemBlue' },
    { name: 'Neon Purple', light: '#A855F7', dark: '#C084FC', var: 'customPurple' },
    { name: 'Glass White', light: 'rgba(255,255,255,0.1)', dark: 'rgba(255,255,255,0.05)', var: 'ultraThinMaterial' },
    { name: 'Glass Border', light: 'rgba(255,255,255,0.2)', dark: 'rgba(255,255,255,0.1)', var: 'regularMaterial' },
  ];

  const spacing = [
    { name: 'xs', value: '4px', rem: '0.25rem' },
    { name: 'sm', value: '8px', rem: '0.5rem' },
    { name: 'md', value: '16px', rem: '1rem' },
    { name: 'lg', value: '24px', rem: '1.5rem' },
    { name: 'xl', value: '32px', rem: '2rem' },
    { name: '2xl', value: '48px', rem: '3rem' },
  ];

  const shadows = [
    { name: 'Glass Soft', css: '0 8px 32px rgba(0, 0, 0, 0.1)', blur: '20px' },
    { name: 'Glass Medium', css: '0 8px 32px rgba(0, 0, 0, 0.2)', blur: '30px' },
    { name: 'Neon Glow', css: '0 0 24px rgba(139, 92, 246, 0.5)', blur: 'radial' },
    { name: 'Card Depth', css: '0 16px 48px rgba(0, 0, 0, 0.3)', blur: '40px' },
  ];

  const typography = [
    { name: 'Display', size: '34px', weight: '600', family: 'SF Pro Display' },
    { name: 'Title 1', size: '28px', weight: '600', family: 'SF Pro Display' },
    { name: 'Title 2', size: '22px', weight: '600', family: 'SF Pro Display' },
    { name: 'Headline', size: '17px', weight: '600', family: 'SF Pro Text' },
    { name: 'Body', size: '17px', weight: '400', family: 'SF Pro Text' },
    { name: 'Caption', size: '13px', weight: '400', family: 'SF Pro Text' },
  ];

  return (
    <div className="space-y-8">
      {/* Colors */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Color Palette
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {colors.map((color, index) => (
            <motion.div
              key={color.name}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
              className={`group p-6 rounded-2xl backdrop-blur-xl border transition-all hover:scale-105 ${
                isDark 
                  ? 'bg-white/5 border-white/10 hover:bg-white/10' 
                  : 'bg-black/5 border-black/10 hover:bg-black/10'
              }`}
            >
              <div 
                className="w-full h-24 rounded-xl mb-4 shadow-lg"
                style={{ 
                  background: isDark ? color.dark : color.light,
                  boxShadow: `0 8px 24px ${isDark ? color.dark : color.light}40`
                }}
              ></div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className={`font-medium ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    {color.name}
                  </span>
                  <button className={`opacity-0 group-hover:opacity-100 transition-opacity ${isDark ? 'text-gray-400 hover:text-white' : 'text-gray-500 hover:text-gray-900'}`}>
                    <Copy className="w-4 h-4" />
                  </button>
                </div>
                <div className={`text-sm font-mono ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                  {isDark ? color.dark : color.light}
                </div>
                <div className={`text-xs ${isDark ? 'text-gray-500' : 'text-gray-500'}`}>
                  {color.var}
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Spacing */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Spacing System
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {spacing.map((space, index) => (
            <motion.div
              key={space.name}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
              className={`p-6 rounded-2xl backdrop-blur-xl border ${
                isDark 
                  ? 'bg-white/5 border-white/10' 
                  : 'bg-black/5 border-black/10'
              }`}
            >
              <div className="flex items-center gap-4">
                <div 
                  className={`rounded-lg ${isDark ? 'bg-violet-500' : 'bg-violet-600'}`}
                  style={{ width: space.value, height: space.value }}
                ></div>
                <div>
                  <div className={`font-semibold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    {space.name}
                  </div>
                  <div className={`text-sm font-mono ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                    {space.value} · {space.rem}
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Shadows & Effects */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Glass Effects & Shadows
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {shadows.map((shadow, index) => (
            <motion.div
              key={shadow.name}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.1 }}
              className={`p-8 rounded-2xl backdrop-blur-xl border ${
                isDark 
                  ? 'bg-white/5 border-white/10' 
                  : 'bg-black/5 border-black/10'
              }`}
            >
              <div 
                className={`w-full h-32 rounded-xl mb-4 flex items-center justify-center ${
                  isDark ? 'bg-white/10' : 'bg-black/10'
                }`}
                style={{ boxShadow: shadow.css }}
              >
                <span className={`font-medium ${isDark ? 'text-white' : 'text-gray-900'}`}>
                  Preview
                </span>
              </div>
              <div className={`font-semibold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                {shadow.name}
              </div>
              <div className={`text-sm font-mono ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                blur: {shadow.blur}
              </div>
              <code className={`text-xs mt-2 block ${isDark ? 'text-gray-500' : 'text-gray-500'}`}>
                {shadow.css}
              </code>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Typography */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Typography Scale
        </h2>
        <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
          isDark 
            ? 'bg-white/5 border-white/10' 
            : 'bg-black/5 border-black/10'
        }`}>
          <div className="space-y-6">
            {typography.map((type, index) => (
              <motion.div
                key={type.name}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.05 }}
                className="border-b border-white/5 pb-4 last:border-0"
              >
                <div 
                  className={isDark ? 'text-white' : 'text-gray-900'}
                  style={{ 
                    fontSize: type.size, 
                    fontWeight: type.weight,
                    fontFamily: type.family 
                  }}
                >
                  The quick brown fox jumps
                </div>
                <div className={`flex gap-4 mt-2 text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                  <span className="font-semibold">{type.name}</span>
                  <span>·</span>
                  <span>{type.size}</span>
                  <span>·</span>
                  <span>{type.weight}</span>
                  <span>·</span>
                  <span>{type.family}</span>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Glassmorphism Breakdown */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Glassmorphism Layers
        </h2>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className={`p-6 rounded-2xl backdrop-blur-none border ${
            isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
          }`}>
            <div className="text-center">
              <div className="mb-3 text-4xl">🔲</div>
              <h3 className={`font-semibold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                Base Layer
              </h3>
              <code className={`text-xs ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                .background(.ultraThinMaterial)
              </code>
            </div>
          </div>

          <div className={`p-6 rounded-2xl backdrop-blur-xl border ${
            isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
          }`}>
            <div className="text-center">
              <div className="mb-3 text-4xl">💨</div>
              <h3 className={`font-semibold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                Blur Effect
              </h3>
              <code className={`text-xs ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                .blur(radius: 20)
              </code>
            </div>
          </div>

          <div className={`p-6 rounded-2xl backdrop-blur-xl border-2 ${
            isDark ? 'bg-white/10 border-white/20' : 'bg-black/10 border-black/20'
          }`} style={{ boxShadow: '0 0 24px rgba(139, 92, 246, 0.3)' }}>
            <div className="text-center">
              <div className="mb-3 text-4xl">✨</div>
              <h3 className={`font-semibold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                Multi-layer Overlay
              </h3>
              <code className={`text-xs ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                .overlay + .fill(.regularMaterial)
              </code>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
