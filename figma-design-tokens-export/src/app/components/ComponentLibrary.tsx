import { useState } from 'react';
import { motion } from 'motion/react';
import { Play, Pause, Users, QrCode, Trophy, Share2 } from 'lucide-react';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Slider } from '@/app/components/ui/slider';

interface ComponentLibraryProps {
  isDark: boolean;
}

export default function ComponentLibrary({ isDark }: ComponentLibraryProps) {
  const [isPressed, setIsPressed] = useState(false);
  const [syncPulse, setSyncPulse] = useState(true);
  const [targetScore, setTargetScore] = useState([500]);

  return (
    <div className="space-y-8">
      {/* Glass Buttons */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Glass Buttons with Hover Effects
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`group relative p-8 rounded-3xl backdrop-blur-xl border-2 transition-all overflow-hidden ${
              isDark 
                ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:border-white/20' 
                : 'bg-black/5 border-black/10 hover:bg-black/10 hover:border-black/20'
            }`}
          >
            {/* Gradient Overlay on Hover */}
            <div className="absolute inset-0 bg-gradient-to-br from-violet-500/10 to-indigo-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
            
            <div className="relative flex flex-col items-center gap-4">
              <div className={`w-16 h-16 rounded-2xl flex items-center justify-center ${
                isDark ? 'bg-violet-500/20' : 'bg-violet-500/30'
              }`}>
                <Users className="w-8 h-8 text-violet-400" />
              </div>
              <div>
                <div className={`text-lg font-semibold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                  Create Room
                </div>
                <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                  2x1 Grid Button
                </div>
              </div>
            </div>
          </motion.button>

          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`group relative p-8 rounded-3xl backdrop-blur-xl border-2 transition-all overflow-hidden ${
              isDark 
                ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:border-white/20' 
                : 'bg-black/5 border-black/10 hover:bg-black/10 hover:border-black/20'
            }`}
          >
            <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/10 to-blue-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
            
            <div className="relative flex flex-col items-center gap-4">
              <div className={`w-16 h-16 rounded-2xl flex items-center justify-center ${
                isDark ? 'bg-indigo-500/20' : 'bg-indigo-500/30'
              }`}>
                <QrCode className="w-8 h-8 text-indigo-400" />
              </div>
              <div>
                <div className={`text-lg font-semibold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                  Join Room
                </div>
                <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                  With Glass Hover
                </div>
              </div>
            </div>
          </motion.button>
        </div>
      </section>

      {/* Scale Effect Demo */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Micro-interactions: .scaleEffect on Tap
        </h2>
        <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <div className="flex flex-col items-center gap-6">
            <motion.button
              animate={{ scale: isPressed ? 0.9 : 1 }}
              transition={{ type: 'spring', stiffness: 400, damping: 20 }}
              onMouseDown={() => setIsPressed(true)}
              onMouseUp={() => setIsPressed(false)}
              onMouseLeave={() => setIsPressed(false)}
              className={`px-12 py-6 rounded-2xl backdrop-blur-xl border-2 font-semibold text-lg ${
                isDark 
                  ? 'bg-violet-500/20 border-violet-500/50 text-white' 
                  : 'bg-violet-500/30 border-violet-500/60 text-gray-900'
              }`}
              style={{ boxShadow: '0 8px 32px rgba(139, 92, 246, 0.3)' }}
            >
              {isPressed ? <Pause className="inline w-5 h-5 mr-2" /> : <Play className="inline w-5 h-5 mr-2" />}
              Press Me
            </motion.button>
            <code className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              .scaleEffect(0.9) + .animation(.spring)
            </code>
          </div>
        </div>
      </section>

      {/* Sync Pulse Animation */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Real-time Sync Pulse (@State Binding)
        </h2>
        <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <div className="flex flex-col items-center gap-6">
            <div className="flex items-center gap-4">
              {[0, 1, 2].map((index) => (
                <motion.div
                  key={index}
                  animate={{
                    scale: syncPulse ? [1, 1.3, 1] : 1,
                    opacity: syncPulse ? [0.5, 1, 0.5] : 0.5,
                  }}
                  transition={{
                    duration: 1.5,
                    repeat: syncPulse ? Infinity : 0,
                    delay: index * 0.2,
                  }}
                  className="w-4 h-4 rounded-full bg-green-500"
                ></motion.div>
              ))}
            </div>
            <button
              onClick={() => setSyncPulse(!syncPulse)}
              className={`px-6 py-3 rounded-xl backdrop-blur-xl border ${
                isDark 
                  ? 'bg-white/10 border-white/20 text-white hover:bg-white/20' 
                  : 'bg-black/10 border-black/20 text-gray-900 hover:bg-black/20'
              } transition-all`}
            >
              {syncPulse ? 'Stop' : 'Start'} Sync
            </button>
            <code className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              withAnimation(.easeInOut(duration: 1.5).repeatForever())
            </code>
          </div>
        </div>
      </section>

      {/* Text Field with Glow */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Text Field with Live Validation Glow
        </h2>
        <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <div className="max-w-md mx-auto space-y-4">
            <Input
              type="text"
              placeholder="Enter 6-digit room code"
              maxLength={6}
              className={`h-16 text-2xl text-center tracking-widest backdrop-blur-xl border-2 transition-all ${
                isDark 
                  ? 'bg-white/5 border-white/10 focus:border-violet-500 text-white placeholder:text-gray-500' 
                  : 'bg-black/5 border-black/10 focus:border-violet-500 text-gray-900 placeholder:text-gray-400'
              }`}
              style={{ 
                boxShadow: '0 0 32px rgba(139, 92, 246, 0.2)',
              }}
            />
            <div className="text-center">
              <code className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                .overlay(RoundedRectangle().stroke(...).shadow(...))
              </code>
            </div>
          </div>
        </div>
      </section>

      {/* Slider/Stepper */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Target Score Stepper/Slider
        </h2>
        <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <div className="max-w-lg mx-auto space-y-6">
            <div className="text-center">
              <div className={`text-5xl font-bold bg-gradient-to-r from-violet-400 to-indigo-400 bg-clip-text text-transparent mb-2`}>
                {targetScore[0]}
              </div>
              <div className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                Target Score
              </div>
            </div>
            <Slider
              value={targetScore}
              onValueChange={setTargetScore}
              min={100}
              max={1000}
              step={50}
              className="w-full"
            />
            <div className={`flex justify-between text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              <span>100</span>
              <span>1000</span>
            </div>
          </div>
        </div>
      </section>

      {/* Winner Badge */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Winner Status Badge
        </h2>
        <div className={`p-12 rounded-2xl backdrop-blur-xl border ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <div className="flex flex-col items-center gap-6">
            <motion.div
              animate={{
                rotate: [0, 5, -5, 0],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut',
              }}
              className="relative"
            >
              <div 
                className={`px-8 py-4 rounded-2xl backdrop-blur-xl border-2 ${
                  isDark ? 'bg-amber-500/20 border-amber-500/50' : 'bg-amber-500/30 border-amber-500/60'
                }`}
                style={{ boxShadow: '0 8px 32px rgba(251, 191, 36, 0.4)' }}
              >
                <div className="flex items-center gap-3">
                  <Trophy className="w-6 h-6 text-amber-400" />
                  <span className={`text-xl font-semibold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Winner: Player 1
                  </span>
                </div>
              </div>
              {/* Glow ring */}
              <motion.div
                animate={{
                  scale: [1, 1.1, 1],
                  opacity: [0.5, 0.8, 0.5],
                }}
                transition={{
                  duration: 2,
                  repeat: Infinity,
                }}
                className="absolute inset-0 rounded-2xl border-2 border-amber-400/50"
              ></motion.div>
            </motion.div>
            <code className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
              .overlay(.regularMaterial) + animation(.spring)
            </code>
          </div>
        </div>
      </section>

      {/* Share Button */}
      <section>
        <h2 className={`text-2xl font-semibold mb-6 ${isDark ? 'text-white' : 'text-gray-900'}`}>
          Share/Copy Buttons with SF Symbols
        </h2>
        <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <div className="flex justify-center gap-4">
            <motion.button
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.9 }}
              className={`p-4 rounded-2xl backdrop-blur-xl border ${
                isDark 
                  ? 'bg-white/10 border-white/20 text-white hover:bg-white/20' 
                  : 'bg-black/10 border-black/20 text-gray-900 hover:bg-black/20'
              } transition-all`}
            >
              <Share2 className="w-6 h-6" />
            </motion.button>
          </div>
        </div>
      </section>
    </div>
  );
}
