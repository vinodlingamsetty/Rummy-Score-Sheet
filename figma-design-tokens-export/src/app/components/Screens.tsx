import { useState } from 'react';
import { motion } from 'motion/react';
import { Smartphone, Tablet, LogIn, Users, QrCode, Grid3x3, Trophy, Sparkles } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/app/components/ui/tabs';

interface ScreensProps {
  isDark: boolean;
}

export default function Screens({ isDark }: ScreensProps) {
  const [deviceType, setDeviceType] = useState<'iphone' | 'ipad'>('iphone');

  const DeviceFrame = ({ children, title }: { children: React.ReactNode; title: string }) => (
    <div className="flex flex-col items-center gap-4">
      <div className={`text-sm font-semibold ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
        {title}
      </div>
      <div 
        className={`relative rounded-[3rem] p-4 backdrop-blur-xl border-4 ${
          isDark ? 'bg-gray-900/50 border-gray-800' : 'bg-gray-100/50 border-gray-300'
        }`}
        style={{
          width: deviceType === 'iphone' ? '390px' : '820px',
          aspectRatio: deviceType === 'iphone' ? '390/844' : '820/1180',
        }}
      >
        {/* Notch/Dynamic Island */}
        {deviceType === 'iphone' && (
          <div className={`absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 rounded-b-3xl ${
            isDark ? 'bg-black' : 'bg-gray-900'
          }`}></div>
        )}
        
        <div className="w-full h-full overflow-hidden rounded-[2.5rem]">
          {children}
        </div>
      </div>
    </div>
  );

  return (
    <div className="space-y-8">
      {/* Device Toggle */}
      <div className="flex justify-center gap-4">
        <button
          onClick={() => setDeviceType('iphone')}
          className={`flex items-center gap-2 px-6 py-3 rounded-xl backdrop-blur-xl border transition-all ${
            deviceType === 'iphone'
              ? isDark 
                ? 'bg-violet-500/20 border-violet-500/50 text-white' 
                : 'bg-violet-500/30 border-violet-500/60 text-gray-900'
              : isDark
                ? 'bg-white/5 border-white/10 text-gray-400 hover:bg-white/10'
                : 'bg-black/5 border-black/10 text-gray-600 hover:bg-black/10'
          }`}
        >
          <Smartphone className="w-5 h-5" />
          iPhone 16 Pro
        </button>
        <button
          onClick={() => setDeviceType('ipad')}
          className={`flex items-center gap-2 px-6 py-3 rounded-xl backdrop-blur-xl border transition-all ${
            deviceType === 'ipad'
              ? isDark 
                ? 'bg-violet-500/20 border-violet-500/50 text-white' 
                : 'bg-violet-500/30 border-violet-500/60 text-gray-900'
              : isDark
                ? 'bg-white/5 border-white/10 text-gray-400 hover:bg-white/10'
                : 'bg-black/5 border-black/10 text-gray-600 hover:bg-black/10'
          }`}
        >
          <Tablet className="w-5 h-5" />
          iPad Pro
        </button>
      </div>

      <Tabs defaultValue="splash" className="w-full">
        <TabsList className={`w-full justify-start backdrop-blur-xl border overflow-x-auto ${
          isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
        }`}>
          <TabsTrigger value="splash">Splash/Login</TabsTrigger>
          <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
          <TabsTrigger value="create">Create Room</TabsTrigger>
          <TabsTrigger value="join">Join Room</TabsTrigger>
          <TabsTrigger value="scoreboard">Scoreboard</TabsTrigger>
          <TabsTrigger value="results">Results</TabsTrigger>
        </TabsList>

        {/* Splash/Login Screen */}
        <TabsContent value="splash" className="mt-8">
          <DeviceFrame title="Splash / Login Screen">
            <div className={`h-full flex flex-col justify-between p-8 ${
              isDark ? 'bg-gradient-to-br from-violet-950 via-indigo-950 to-purple-950' : 'bg-gradient-to-br from-violet-100 via-indigo-100 to-purple-100'
            }`}>
              {/* Animated Playing Cards Background */}
              <div className="absolute inset-0 overflow-hidden opacity-10">
                {[...Array(8)].map((_, i) => (
                  <motion.div
                    key={i}
                    className={`absolute w-24 h-32 rounded-lg ${isDark ? 'bg-white/20' : 'bg-black/20'}`}
                    initial={{ y: -100, rotate: -15 }}
                    animate={{ 
                      y: '100vh',
                      rotate: i % 2 === 0 ? 360 : -360,
                    }}
                    transition={{
                      duration: 8 + i,
                      repeat: Infinity,
                      delay: i * 0.5,
                    }}
                    style={{
                      left: `${i * 12}%`,
                    }}
                  >
                    <div className="absolute inset-2 flex items-center justify-center text-4xl">
                      {['♠', '♥', '♣', '♦'][i % 4]}
                    </div>
                  </motion.div>
                ))}
              </div>

              {/* Logo & Title */}
              <div className="relative z-10 text-center pt-24">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: 'spring', duration: 0.8 }}
                >
                  <Sparkles className="w-20 h-20 mx-auto text-violet-400 mb-6" />
                </motion.div>
                <h1 className={`text-4xl font-bold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                  Rummy Score
                </h1>
                <p className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                  Track your game with style
                </p>
              </div>

              {/* Google Sign-In Button */}
              <div className="relative z-10 space-y-4">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className={`w-full py-5 rounded-2xl backdrop-blur-xl border-2 flex items-center justify-center gap-3 transition-all ${
                    isDark 
                      ? 'bg-white/10 border-white/20 text-white hover:bg-white/20' 
                      : 'bg-black/10 border-black/20 text-gray-900 hover:bg-black/20'
                  }`}
                  style={{ boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2)' }}
                >
                  <LogIn className="w-6 h-6" />
                  <span className="font-semibold text-lg">Sign in with Google</span>
                </motion.button>
                <p className={`text-xs text-center ${isDark ? 'text-gray-500' : 'text-gray-500'}`}>
                  SF Symbols + Glass Morphism
                </p>
              </div>
            </div>
          </DeviceFrame>
        </TabsContent>

        {/* Dashboard Screen */}
        <TabsContent value="dashboard" className="mt-8">
          <DeviceFrame title="Dashboard - 2x1 Grid Buttons">
            <div className={`h-full p-8 ${
              isDark ? 'bg-gradient-to-br from-gray-900 via-violet-950 to-indigo-950' : 'bg-gradient-to-br from-gray-50 via-violet-50 to-indigo-50'
            }`}>
              <div className="h-full flex flex-col justify-between">
                <div>
                  <h1 className={`text-3xl font-bold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Dashboard
                  </h1>
                  <p className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                    Choose an option
                  </p>
                </div>

                <div className="grid grid-cols-1 gap-6">
                  <motion.button
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className={`group relative p-12 rounded-3xl backdrop-blur-xl border-2 transition-all overflow-hidden ${
                      isDark 
                        ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:border-white/20' 
                        : 'bg-black/5 border-black/10 hover:bg-black/10 hover:border-black/20'
                    }`}
                  >
                    <div className="absolute inset-0 bg-gradient-to-br from-violet-500/20 to-indigo-500/20 opacity-0 group-hover:opacity-100 transition-opacity"></div>
                    <div className="relative flex items-center gap-6">
                      <div className={`w-20 h-20 rounded-2xl flex items-center justify-center ${
                        isDark ? 'bg-violet-500/20' : 'bg-violet-500/30'
                      }`}>
                        <Users className="w-10 h-10 text-violet-400" />
                      </div>
                      <div className="text-left">
                        <div className={`text-2xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                          Create Room
                        </div>
                        <div className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                          Start a new game
                        </div>
                      </div>
                    </div>
                  </motion.button>

                  <motion.button
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className={`group relative p-12 rounded-3xl backdrop-blur-xl border-2 transition-all overflow-hidden ${
                      isDark 
                        ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:border-white/20' 
                        : 'bg-black/5 border-black/10 hover:bg-black/10 hover:border-black/20'
                    }`}
                  >
                    <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/20 to-blue-500/20 opacity-0 group-hover:opacity-100 transition-opacity"></div>
                    <div className="relative flex items-center gap-6">
                      <div className={`w-20 h-20 rounded-2xl flex items-center justify-center ${
                        isDark ? 'bg-indigo-500/20' : 'bg-indigo-500/30'
                      }`}>
                        <QrCode className="w-10 h-10 text-indigo-400" />
                      </div>
                      <div className="text-left">
                        <div className={`text-2xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                          Join Room
                        </div>
                        <div className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                          Enter room code
                        </div>
                      </div>
                    </div>
                  </motion.button>
                </div>

                <div className="h-20"></div>
              </div>
            </div>
          </DeviceFrame>
        </TabsContent>

        {/* Create Room Sheet */}
        <TabsContent value="create" className="mt-8">
          <DeviceFrame title="Create Room Sheet">
            <div className={`h-full p-8 ${
              isDark ? 'bg-gradient-to-br from-gray-900 via-violet-950 to-indigo-950' : 'bg-gradient-to-br from-gray-50 via-violet-50 to-indigo-50'
            }`}>
              <div className="space-y-8">
                <div>
                  <h2 className={`text-2xl font-bold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Create Room
                  </h2>
                  <p className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                    Set up your game
                  </p>
                </div>

                {/* Room Code */}
                <div className={`p-8 rounded-2xl backdrop-blur-xl border ${
                  isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
                }`}>
                  <div className="text-center space-y-4">
                    <div className={`text-sm font-semibold ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                      ROOM CODE
                    </div>
                    <div className="text-5xl font-bold tracking-wider text-violet-400">
                      A7K3M9
                    </div>
                    <div className="flex gap-3 justify-center pt-4">
                      <button className={`px-6 py-3 rounded-xl backdrop-blur-xl border ${
                        isDark ? 'bg-white/10 border-white/20 text-white hover:bg-white/20' : 'bg-black/10 border-black/20 text-gray-900 hover:bg-black/20'
                      } transition-all`}>
                        Copy
                      </button>
                      <button className={`px-6 py-3 rounded-xl backdrop-blur-xl border ${
                        isDark ? 'bg-white/10 border-white/20 text-white hover:bg-white/20' : 'bg-black/10 border-black/20 text-gray-900 hover:bg-black/20'
                      } transition-all`}>
                        Share
                      </button>
                    </div>
                  </div>
                </div>

                {/* Target Score */}
                <div>
                  <div className={`text-sm font-semibold mb-4 ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                    TARGET SCORE
                  </div>
                  <div className={`p-6 rounded-2xl backdrop-blur-xl border ${
                    isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
                  }`}>
                    <div className="text-center">
                      <div className="text-4xl font-bold bg-gradient-to-r from-violet-400 to-indigo-400 bg-clip-text text-transparent mb-4">
                        500
                      </div>
                      <div className={`h-2 rounded-full ${isDark ? 'bg-white/10' : 'bg-black/10'}`}>
                        <div className="h-full w-1/2 rounded-full bg-gradient-to-r from-violet-500 to-indigo-500"></div>
                      </div>
                      <div className={`flex justify-between mt-2 text-xs ${isDark ? 'text-gray-500' : 'text-gray-500'}`}>
                        <span>100</span>
                        <span>1000</span>
                      </div>
                    </div>
                  </div>
                </div>

                <button className={`w-full py-5 rounded-2xl backdrop-blur-xl border-2 font-semibold text-lg ${
                  isDark 
                    ? 'bg-violet-500/20 border-violet-500/50 text-white' 
                    : 'bg-violet-500/30 border-violet-500/60 text-gray-900'
                }`}>
                  Start Game
                </button>
              </div>
            </div>
          </DeviceFrame>
        </TabsContent>

        {/* Join Room */}
        <TabsContent value="join" className="mt-8">
          <DeviceFrame title="Join Room - QR Scanner">
            <div className={`h-full p-8 flex flex-col justify-center ${
              isDark ? 'bg-gradient-to-br from-gray-900 via-violet-950 to-indigo-950' : 'bg-gradient-to-br from-gray-50 via-violet-50 to-indigo-50'
            }`}>
              <div className="space-y-8">
                <div className="text-center">
                  <h2 className={`text-3xl font-bold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Join Room
                  </h2>
                  <p className={`${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                    Enter code or scan QR
                  </p>
                </div>

                {/* Large Text Field */}
                <div className="relative">
                  <input
                    type="text"
                    placeholder="000000"
                    maxLength={6}
                    className={`w-full h-24 text-5xl text-center tracking-widest backdrop-blur-xl border-2 rounded-3xl transition-all ${
                      isDark 
                        ? 'bg-white/5 border-white/10 focus:border-violet-500 text-white placeholder:text-gray-600' 
                        : 'bg-black/5 border-black/10 focus:border-violet-500 text-gray-900 placeholder:text-gray-400'
                    }`}
                    style={{ 
                      boxShadow: '0 0 48px rgba(139, 92, 246, 0.3)',
                      outline: 'none',
                    }}
                  />
                </div>

                {/* QR Scanner Button */}
                <button className={`w-full p-8 rounded-3xl backdrop-blur-xl border-2 transition-all ${
                  isDark 
                    ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:border-white/20' 
                    : 'bg-black/5 border-black/10 hover:bg-black/10 hover:border-black/20'
                }`}>
                  <QrCode className="w-16 h-16 mx-auto mb-4 text-indigo-400" />
                  <div className={`font-semibold text-lg ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Scan QR Code
                  </div>
                </button>
              </div>
            </div>
          </DeviceFrame>
        </TabsContent>

        {/* Scoreboard */}
        <TabsContent value="scoreboard" className="mt-8">
          <DeviceFrame title="Scoreboard - 4 Players × 15 Rounds">
            <div className={`h-full ${
              isDark ? 'bg-gradient-to-br from-gray-900 via-violet-950 to-indigo-950' : 'bg-gradient-to-br from-gray-50 via-violet-50 to-indigo-50'
            }`}>
              {/* Glass Header */}
              <div className={`p-4 backdrop-blur-xl border-b sticky top-0 z-10 ${
                isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
              }`}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <motion.div
                      animate={{ scale: [1, 1.2, 1], opacity: [0.5, 1, 0.5] }}
                      transition={{ duration: 1.5, repeat: Infinity }}
                      className="w-2 h-2 rounded-full bg-green-500"
                    ></motion.div>
                    <span className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                      Synced
                    </span>
                  </div>
                  <div className={`text-lg font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Target: 500
                  </div>
                </div>
              </div>

              {/* Scoreboard Grid */}
              <div className="p-4 space-y-2 overflow-y-auto" style={{ height: 'calc(100% - 120px)' }}>
                <div className="grid grid-cols-5 gap-2">
                  <div className={`p-2 text-xs font-semibold ${isDark ? 'text-gray-500' : 'text-gray-500'}`}>
                    Round
                  </div>
                  {['P1', 'P2', 'P3', 'P4'].map((player) => (
                    <div key={player} className={`p-2 text-xs font-semibold text-center ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>
                      {player}
                    </div>
                  ))}
                </div>

                {[...Array(5)].map((_, round) => (
                  <div key={round} className="grid grid-cols-5 gap-2">
                    <div className={`p-3 rounded-lg text-center ${isDark ? 'bg-white/5 text-gray-400' : 'bg-black/5 text-gray-600'}`}>
                      {round + 1}
                    </div>
                    {[...Array(4)].map((_, player) => (
                      <input
                        key={player}
                        type="number"
                        placeholder="0"
                        className={`p-3 rounded-lg text-center backdrop-blur-xl border ${
                          isDark 
                            ? 'bg-white/5 border-white/10 text-white placeholder:text-gray-600' 
                            : 'bg-black/5 border-black/10 text-gray-900 placeholder:text-gray-400'
                        }`}
                      />
                    ))}
                  </div>
                ))}
              </div>

              {/* Glass Footer */}
              <div className={`p-4 backdrop-blur-xl border-t sticky bottom-0 ${
                isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
              }`}>
                <button className={`w-full py-3 rounded-xl backdrop-blur-xl border ${
                  isDark ? 'bg-red-500/20 border-red-500/50 text-red-400' : 'bg-red-500/30 border-red-500/60 text-red-600'
                }`}>
                  Leave Game
                </button>
              </div>
            </div>
          </DeviceFrame>
        </TabsContent>

        {/* Results */}
        <TabsContent value="results" className="mt-8">
          <DeviceFrame title="Game Results - Confetti Animation">
            <div className={`h-full p-8 flex flex-col justify-center relative overflow-hidden ${
              isDark ? 'bg-gradient-to-br from-gray-900 via-violet-950 to-indigo-950' : 'bg-gradient-to-br from-gray-50 via-violet-50 to-indigo-50'
            }`}>
              {/* Confetti Effect */}
              <div className="absolute inset-0 pointer-events-none">
                {[...Array(20)].map((_, i) => (
                  <motion.div
                    key={i}
                    className="absolute w-3 h-3 rounded-full"
                    style={{
                      background: ['#8B5CF6', '#3B82F6', '#F59E0B', '#EC4899'][i % 4],
                      left: `${i * 5}%`,
                    }}
                    initial={{ y: -20, opacity: 1 }}
                    animate={{ 
                      y: '100vh',
                      opacity: 0,
                      rotate: 360,
                    }}
                    transition={{
                      duration: 3 + i * 0.2,
                      repeat: Infinity,
                      delay: i * 0.1,
                    }}
                  ></motion.div>
                ))}
              </div>

              <div className="space-y-8 relative z-10">
                {/* Trophy */}
                <motion.div
                  animate={{ 
                    rotate: [0, 5, -5, 0],
                    scale: [1, 1.1, 1],
                  }}
                  transition={{ 
                    duration: 2,
                    repeat: Infinity,
                  }}
                  className="flex justify-center"
                >
                  <Trophy className="w-32 h-32 text-amber-400" />
                </motion.div>

                {/* Winner Announcement */}
                <div className="text-center space-y-4">
                  <h2 className={`text-4xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                    Winner!
                  </h2>
                  <div className={`p-6 rounded-2xl backdrop-blur-xl border-2 ${
                    isDark 
                      ? 'bg-amber-500/20 border-amber-500/50' 
                      : 'bg-amber-500/30 border-amber-500/60'
                  }`} style={{ boxShadow: '0 8px 32px rgba(251, 191, 36, 0.4)' }}>
                    <div className={`text-3xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                      Player 1
                    </div>
                    <div className={`text-xl ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
                      Score: 125
                    </div>
                  </div>
                </div>

                {/* Final Scores */}
                <div className="space-y-3">
                  {[
                    { name: 'Player 2', score: 210 },
                    { name: 'Player 3', score: 387 },
                    { name: 'Player 4', score: 445 },
                  ].map((player, index) => (
                    <div
                      key={player.name}
                      className={`flex justify-between p-4 rounded-xl backdrop-blur-xl border ${
                        isDark ? 'bg-white/5 border-white/10' : 'bg-black/5 border-black/10'
                      }`}
                    >
                      <span className={isDark ? 'text-white' : 'text-gray-900'}>
                        {player.name}
                      </span>
                      <span className={isDark ? 'text-gray-400' : 'text-gray-600'}>
                        {player.score}
                      </span>
                    </div>
                  ))}
                </div>

                {/* Actions */}
                <div className="flex gap-3">
                  <button className={`flex-1 py-4 rounded-xl backdrop-blur-xl border font-semibold ${
                    isDark 
                      ? 'bg-violet-500/20 border-violet-500/50 text-white' 
                      : 'bg-violet-500/30 border-violet-500/60 text-gray-900'
                  }`}>
                    Play Again
                  </button>
                  <button className={`flex-1 py-4 rounded-xl backdrop-blur-xl border font-semibold ${
                    isDark 
                      ? 'bg-white/10 border-white/20 text-white' 
                      : 'bg-black/10 border-black/20 text-gray-900'
                  }`}>
                    Share Results
                  </button>
                </div>
              </div>
            </div>
          </DeviceFrame>
        </TabsContent>
      </Tabs>
    </div>
  );
}
