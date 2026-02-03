import { useState } from 'react';
import { Home, Users, BookOpen, UserCircle, Trophy } from 'lucide-react';
import { motion } from 'motion/react';
import type { User } from '@/app/App';
import HomeTab from '@/app/components/tabs/HomeTab';
import CurrentGameTab from '@/app/components/tabs/CurrentGameTab';
import FriendsTab from '@/app/components/tabs/FriendsTab';
import RulesTab from '@/app/components/tabs/RulesTab';
import ProfileTab from '@/app/components/tabs/ProfileTab';

interface MainAppProps {
  currentUser: User;
  onLogout: () => void;
}

export type GameRoom = {
  id: string;
  code: string;
  moderatorId: string;
  pointLimit: number;
  betAmount: number;
  players: Player[];
  status: 'lobby' | 'playing' | 'finished';
  currentRound: number;
  scores: Record<string, number[]>;
};

export type Player = {
  id: string;
  firstName: string;
  lastName: string;
  avatar: string;
  isReady: boolean;
};

export type Friend = {
  id: string;
  firstName: string;
  lastName: string;
  avatar: string;
  balance: number;
  isPending?: boolean;
};

export type GameHistory = {
  id: string;
  date: string;
  roomCode: string;
  players: { name: string; score: number; won: boolean }[];
  betAmount: number;
  winner: string;
};

export default function MainApp({ currentUser, onLogout }: MainAppProps) {
  // Set Game tab as the default active tab
  const [activeTab, setActiveTab] = useState<'home' | 'game' | 'friends' | 'rules' | 'profile'>('game');
  
  // Initialize with a mock game room for demo purposes
  const [currentRoom, setCurrentRoom] = useState<GameRoom | null>({
    id: 'room_demo123',
    code: 'DEMO99',
    moderatorId: currentUser.id,
    pointLimit: 500,
    betAmount: 10,
    players: [
      {
        id: currentUser.id,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        avatar: currentUser.avatar,
        isReady: true,
      },
      {
        id: 'player_2',
        firstName: 'Jane',
        lastName: 'Smith',
        avatar: '👩',
        isReady: true,
      },
      {
        id: 'player_3',
        firstName: 'Mike',
        lastName: 'Johnson',
        avatar: '👨',
        isReady: true,
      },
      {
        id: 'player_4',
        firstName: 'Sarah',
        lastName: 'Williams',
        avatar: '👧',
        isReady: true,
      },
    ],
    status: 'playing',
    currentRound: 3,
    scores: {
      [currentUser.id]: [45, 0, 23],
      'player_2': [12, 67, 34],
      'player_3': [89, 23, 56],
      'player_4': [0, 45, 12],
    },
  });

  const tabs = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'game', label: 'Game', icon: Trophy },
    { id: 'friends', label: 'Friends', icon: Users },
    { id: 'rules', label: 'Rules', icon: BookOpen },
    { id: 'profile', label: 'Profile', icon: UserCircle },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0a0015] via-[#1a0b2e] to-[#0f0520] relative overflow-hidden">
      {/* Background Gradient Orbs */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute w-[600px] h-[600px] rounded-full bg-gradient-to-br from-purple-600/20 to-indigo-600/20 blur-3xl -top-48 -right-48 animate-pulse" 
             style={{ animationDuration: '8s' }} />
        <div className="absolute w-[500px] h-[500px] rounded-full bg-gradient-to-br from-blue-600/15 to-violet-600/15 blur-3xl -bottom-32 -left-32 animate-pulse" 
             style={{ animationDuration: '10s' }} />
      </div>

      {/* Status Bar Space */}
      <div className="h-[max(env(safe-area-inset-top),44px)] bg-transparent" />

      {/* Main Content */}
      <div className="relative z-10" style={{ paddingBottom: 'calc(80px + env(safe-area-inset-bottom))' }}>
        <motion.div
          key={activeTab}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30 }}
        >
          {activeTab === 'home' && (
            <HomeTab 
              currentUser={currentUser} 
              currentRoom={currentRoom}
              setCurrentRoom={setCurrentRoom}
              setActiveTab={setActiveTab}
            />
          )}
          {activeTab === 'game' && (
            <CurrentGameTab 
              currentUser={currentUser} 
              currentRoom={currentRoom}
              setCurrentRoom={setCurrentRoom}
              setActiveTab={setActiveTab}
            />
          )}
          {activeTab === 'friends' && <FriendsTab currentUser={currentUser} />}
          {activeTab === 'rules' && <RulesTab />}
          {activeTab === 'profile' && <ProfileTab currentUser={currentUser} onLogout={onLogout} />}
        </motion.div>
      </div>

      {/* iOS Tab Bar */}
      <div className="fixed bottom-0 left-0 right-0 z-50" 
           style={{ paddingBottom: 'max(env(safe-area-inset-bottom), 0px)' }}>
        <div className="ios-blur-thick border-t border-white/10" 
             style={{ 
               background: 'rgba(28, 28, 30, 0.8)',
               boxShadow: '0 -2px 20px rgba(0, 0, 0, 0.3)',
             }}>
          <div className="max-w-2xl mx-auto px-2 pt-2 pb-1">
            <div className="flex items-center justify-around">
              {tabs.map((tab) => {
                const Icon = tab.icon;
                const isActive = activeTab === tab.id;
                
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id as any)}
                    className="flex flex-col items-center gap-1 py-1 px-4 rounded-xl transition-all relative"
                  >
                    {isActive && (
                      <motion.div
                        layoutId="activeTab"
                        className="absolute inset-0 rounded-xl"
                        style={{
                          background: 'rgba(120, 120, 128, 0.2)',
                        }}
                        transition={{ type: 'spring', stiffness: 400, damping: 30 }}
                      />
                    )}
                    
                    <motion.div
                      animate={{
                        scale: isActive ? 1.05 : 1,
                        y: isActive ? -2 : 0,
                      }}
                      transition={{ type: 'spring', stiffness: 400, damping: 25 }}
                      className="relative z-10"
                    >
                      <Icon 
                        className={`w-6 h-6 transition-colors ${
                          isActive 
                            ? 'text-[#0A84FF]' 
                            : 'text-gray-400'
                        }`}
                        strokeWidth={isActive ? 2.5 : 2}
                      />
                    </motion.div>
                    
                    <span className={`text-[10px] font-medium transition-colors relative z-10 ${
                      isActive 
                        ? 'text-[#0A84FF]' 
                        : 'text-gray-400'
                    }`}>
                      {tab.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
          
          {/* iOS Home Indicator */}
          <div className="flex justify-center pt-1 pb-2">
            <div className="w-36 h-1 bg-white/30 rounded-full" />
          </div>
        </div>
      </div>
    </div>
  );
}