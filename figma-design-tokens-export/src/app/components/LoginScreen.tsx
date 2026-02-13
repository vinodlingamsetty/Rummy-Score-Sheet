import { useState } from 'react';
import { motion } from 'motion/react';
import { Sparkles } from 'lucide-react';
import type { User } from '@/app/App';

interface LoginScreenProps {
  onLogin: (user: User) => void;
}

export default function LoginScreen({ onLogin }: LoginScreenProps) {
  const [isLoading, setIsLoading] = useState(false);

  const handleGoogleLogin = () => {
    setIsLoading(true);
    
    setTimeout(() => {
      const mockUser: User = {
        id: 'user_' + Math.random().toString(36).substr(2, 9),
        email: 'player@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '👤',
      };
      onLogin(mockUser);
      setIsLoading(false);
    }, 1500);
  };

  return (
    <div className="min-h-screen flex flex-col justify-between p-6 pb-8 bg-gradient-to-br from-[#1a0b2e] via-[#2d1b4e] to-[#0f0520] relative overflow-hidden">
      {/* iOS Dynamic Island Space */}
      <div className="h-[max(env(safe-area-inset-top),20px)]" />
      
      {/* Animated Gradient Orbs - iOS 26 Style */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute w-[500px] h-[500px] rounded-full bg-gradient-to-br from-purple-500/30 to-indigo-500/30 blur-3xl"
          animate={{
            x: [-100, 100, -100],
            y: [-100, 150, -100],
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "easeInOut",
          }}
          style={{ top: '10%', left: '10%' }}
        />
        <motion.div
          className="absolute w-[400px] h-[400px] rounded-full bg-gradient-to-br from-blue-500/20 to-violet-500/20 blur-3xl"
          animate={{
            x: [100, -100, 100],
            y: [100, -100, 100],
            scale: [1.2, 1, 1.2],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: "easeInOut",
          }}
          style={{ bottom: '20%', right: '10%' }}
        />
      </div>

      {/* Floating Cards */}
      <div className="absolute inset-0 overflow-hidden opacity-10 pointer-events-none">
        {[...Array(8)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-20 h-28 rounded-2xl ios-blur-thin border border-white/10"
            initial={{ y: -100, rotate: -15, opacity: 0 }}
            animate={{ 
              y: '110vh',
              rotate: i % 2 === 0 ? 360 : -360,
              opacity: [0, 0.3, 0.3, 0],
            }}
            transition={{
              duration: 12 + i * 2,
              repeat: Infinity,
              delay: i * 1.5,
              ease: "linear",
            }}
            style={{
              left: `${i * 12}%`,
            }}
          >
            <div className="absolute inset-0 flex items-center justify-center text-4xl">
              {['♠', '♥', '♣', '♦'][i % 4]}
            </div>
          </motion.div>
        ))}
      </div>

      {/* Logo & Title */}
      <div className="relative z-10 text-center pt-20">
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ 
            type: 'spring',
            stiffness: 200,
            damping: 15,
            duration: 0.8 
          }}
          className="mb-8"
        >
          <div className="w-28 h-28 mx-auto rounded-[32px] ios-blur-thick border border-white/20 flex items-center justify-center shadow-2xl"
               style={{ 
                 background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.3) 0%, rgba(99, 102, 241, 0.3) 100%)',
               }}>
            <Sparkles className="w-14 h-14 text-white drop-shadow-lg" />
          </div>
        </motion.div>
        
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.6 }}
        >
          <h1 className="text-5xl font-bold mb-3 text-white tracking-tight">
            Rummy Score
          </h1>
          <p className="text-xl text-white/70 font-medium">
            Track your game with friends
          </p>
        </motion.div>
      </div>

      {/* Login Button - iOS Style */}
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5, duration: 0.6 }}
        className="relative z-10 space-y-4"
      >
        <motion.button
          whileTap={{ scale: 0.96 }}
          onClick={handleGoogleLogin}
          disabled={isLoading}
          className="w-full relative overflow-hidden rounded-[16px] ios-blur-regular border border-white/20 disabled:opacity-50 shadow-xl"
          style={{
            background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.25) 0%, rgba(99, 102, 241, 0.25) 100%)',
          }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/10 to-white/0 opacity-0 hover:opacity-100 transition-opacity duration-500" />
          
          <div className="relative px-8 py-5 flex items-center justify-center gap-3">
            {isLoading ? (
              <>
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="w-6 h-6 rounded-full border-3 border-white/30 border-t-white"
                />
                <span className="text-xl font-semibold text-white tracking-tight">
                  Signing in...
                </span>
              </>
            ) : (
              <>
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="white">
                  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                <span className="text-xl font-semibold text-white tracking-tight">
                  Sign in with Google
                </span>
              </>
            )}
          </div>
        </motion.button>
        
        <p className="text-center text-sm text-white/50 font-medium px-4">
          Demo Mode • Tap to continue with mock account
        </p>
      </motion.div>

      {/* iOS Home Indicator */}
      <div className="h-[max(env(safe-area-inset-bottom),20px)] flex items-end justify-center pb-2">
        <div className="w-36 h-1.5 bg-white/30 rounded-full" />
      </div>
    </div>
  );
}
