import { useState } from 'react';
import { motion } from 'motion/react';
import { Plus, QrCode, History, ChevronRight } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/app/components/ui/dialog';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import type { User } from '@/app/App';
import type { GameRoom, GameHistory } from '@/app/components/MainApp';

interface HomeTabProps {
  currentUser: User;
  currentRoom: GameRoom | null;
  setCurrentRoom: (room: GameRoom | null) => void;
  setActiveTab: (tab: 'home' | 'game' | 'friends' | 'rules' | 'profile') => void;
}

const mockGameHistory: GameHistory[] = [
  {
    id: 'game1',
    date: '2026-01-29',
    roomCode: 'A7K3M9',
    players: [
      { name: 'John Doe', score: 125, won: true },
      { name: 'Jane Smith', score: 210, won: false },
      { name: 'Mike Johnson', score: 387, won: false },
      { name: 'Sarah Williams', score: 445, won: false },
    ],
    betAmount: 10,
    winner: 'John Doe',
  },
  {
    id: 'game2',
    date: '2026-01-28',
    roomCode: 'B2M5N8',
    players: [
      { name: 'John Doe', score: 512, won: false },
      { name: 'Alex Brown', score: 198, won: true },
      { name: 'Emma Davis', score: 423, won: false },
    ],
    betAmount: 5,
    winner: 'Alex Brown',
  },
];

export default function HomeTab({ currentUser, currentRoom, setCurrentRoom, setActiveTab }: HomeTabProps) {
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [showJoinDialog, setShowJoinDialog] = useState(false);
  const [showHistoryDialog, setShowHistoryDialog] = useState(false);
  
  const [pointLimit, setPointLimit] = useState(500);
  const [betAmount, setBetAmount] = useState(10);
  const [joinCode, setJoinCode] = useState('');

  const handleCreateRoom = () => {
    const roomCode = Math.random().toString(36).substr(2, 6).toUpperCase();
    const newRoom: GameRoom = {
      id: 'room_' + Math.random().toString(36).substr(2, 9),
      code: roomCode,
      moderatorId: currentUser.id,
      pointLimit,
      betAmount,
      players: [{
        id: currentUser.id,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        avatar: currentUser.avatar,
        isReady: false,
      }],
      status: 'lobby',
      currentRound: 1,
      scores: {},
    };
    
    setCurrentRoom(newRoom);
    setShowCreateDialog(false);
    setActiveTab('game');
  };

  const handleJoinRoom = () => {
    const mockRoom: GameRoom = {
      id: 'room_' + Math.random().toString(36).substr(2, 9),
      code: joinCode,
      moderatorId: 'other_user_123',
      pointLimit: 500,
      betAmount: 10,
      players: [
        {
          id: 'other_user_123',
          firstName: 'Jane',
          lastName: 'Smith',
          avatar: '👩',
          isReady: true,
        },
        {
          id: currentUser.id,
          firstName: currentUser.firstName,
          lastName: currentUser.lastName,
          avatar: currentUser.avatar,
          isReady: false,
        },
      ],
      status: 'lobby',
      currentRound: 1,
      scores: {},
    };
    
    setCurrentRoom(mockRoom);
    setShowJoinDialog(false);
    setActiveTab('game');
  };

  return (
    <div className="min-h-screen px-4 pb-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-4xl font-bold text-white mb-1 tracking-tight">
          Welcome Back
        </h1>
        <p className="text-lg text-white/60 font-medium">{currentUser.firstName}</p>
      </motion.div>

      {/* Main Action Cards */}
      <div className="space-y-3 mb-8">
        <Dialog open={showCreateDialog} onOpenChange={setShowCreateDialog}>
          <DialogTrigger asChild>
            <motion.button
              whileTap={{ scale: 0.97 }}
              className="w-full group relative overflow-hidden rounded-[20px] ios-blur-regular border border-white/10 text-left shadow-xl"
              style={{
                background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(99, 102, 241, 0.2) 100%)',
              }}
            >
              <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/5 to-white/0 opacity-0 group-active:opacity-100 transition-opacity" />
              
              <div className="relative p-5 flex items-center gap-4">
                <div className="w-14 h-14 rounded-[16px] flex items-center justify-center"
                     style={{
                       background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.3) 0%, rgba(99, 102, 241, 0.3) 100%)',
                     }}>
                  <Plus className="w-7 h-7 text-white" strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <div className="text-xl font-semibold text-white mb-0.5 tracking-tight">Create Room</div>
                  <div className="text-sm text-white/60 font-medium">Start a new game session</div>
                </div>
                <ChevronRight className="w-6 h-6 text-white/40 group-active:text-white/60 transition-colors" strokeWidth={2.5} />
              </div>
            </motion.button>
          </DialogTrigger>
          
          <DialogContent className="ios-blur-thick border-white/10 rounded-[24px] shadow-2xl"
                         style={{ background: 'rgba(28, 28, 30, 0.95)' }}>
            <DialogHeader>
              <DialogTitle className="text-white text-2xl font-bold tracking-tight">Create New Room</DialogTitle>
            </DialogHeader>
            <div className="space-y-5 py-4">
              <div>
                <Label className="text-white/80 text-base font-semibold mb-2 block">Point Limit</Label>
                <Input
                  type="number"
                  value={pointLimit}
                  onChange={(e) => setPointLimit(Number(e.target.value))}
                  className="ios-blur-thin bg-white/5 border-white/10 text-white text-lg h-14 rounded-[14px] px-4"
                />
              </div>
              <div>
                <Label className="text-white/80 text-base font-semibold mb-2 block">Bet Amount ($)</Label>
                <Input
                  type="number"
                  value={betAmount}
                  onChange={(e) => setBetAmount(Number(e.target.value))}
                  className="ios-blur-thin bg-white/5 border-white/10 text-white text-lg h-14 rounded-[14px] px-4"
                />
              </div>
              <motion.button
                whileTap={{ scale: 0.97 }}
                onClick={handleCreateRoom}
                className="w-full h-14 rounded-[14px] text-white text-lg font-semibold shadow-lg"
                style={{
                  background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
                }}
              >
                Create Room
              </motion.button>
            </div>
          </DialogContent>
        </Dialog>

        <Dialog open={showJoinDialog} onOpenChange={setShowJoinDialog}>
          <DialogTrigger asChild>
            <motion.button
              whileTap={{ scale: 0.97 }}
              className="w-full group relative overflow-hidden rounded-[20px] ios-blur-regular border border-white/10 text-left shadow-xl"
              style={{
                background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.2) 0%, rgba(59, 130, 246, 0.2) 100%)',
              }}
            >
              <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/5 to-white/0 opacity-0 group-active:opacity-100 transition-opacity" />
              
              <div className="relative p-5 flex items-center gap-4">
                <div className="w-14 h-14 rounded-[16px] flex items-center justify-center"
                     style={{
                       background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.3) 0%, rgba(59, 130, 246, 0.3) 100%)',
                     }}>
                  <QrCode className="w-7 h-7 text-white" strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <div className="text-xl font-semibold text-white mb-0.5 tracking-tight">Join Room</div>
                  <div className="text-sm text-white/60 font-medium">Enter a room code</div>
                </div>
                <ChevronRight className="w-6 h-6 text-white/40 group-active:text-white/60 transition-colors" strokeWidth={2.5} />
              </div>
            </motion.button>
          </DialogTrigger>
          
          <DialogContent className="ios-blur-thick border-white/10 rounded-[24px] shadow-2xl"
                         style={{ background: 'rgba(28, 28, 30, 0.95)' }}>
            <DialogHeader>
              <DialogTitle className="text-white text-2xl font-bold tracking-tight">Join Room</DialogTitle>
            </DialogHeader>
            <div className="space-y-5 py-4">
              <div>
                <Label className="text-white/80 text-base font-semibold mb-2 block">Room Code</Label>
                <Input
                  type="text"
                  placeholder="A1B2C3"
                  maxLength={6}
                  value={joinCode}
                  onChange={(e) => setJoinCode(e.target.value.toUpperCase())}
                  className="ios-blur-thin bg-white/5 border-white/10 text-white text-center text-3xl tracking-[0.3em] h-20 rounded-[14px] font-bold"
                />
              </div>
              <motion.button
                whileTap={{ scale: 0.97 }}
                onClick={handleJoinRoom}
                disabled={joinCode.length !== 6}
                className="w-full h-14 rounded-[14px] text-white text-lg font-semibold disabled:opacity-40 shadow-lg"
                style={{
                  background: 'linear-gradient(135deg, #6366F1 0%, #3B82F6 100%)',
                }}
              >
                Join Room
              </motion.button>
              <div className="text-center pt-2">
                <button className="text-sm text-[#0A84FF] font-semibold flex items-center gap-2 mx-auto">
                  <QrCode className="w-4 h-4" />
                  Scan QR Code
                </button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Game History */}
      <div>
        <div className="flex items-center justify-between mb-3 px-1">
          <h2 className="text-2xl font-bold text-white tracking-tight">Recent Games</h2>
          <button 
            onClick={() => setShowHistoryDialog(true)}
            className="text-[#0A84FF] font-semibold text-base flex items-center gap-1"
          >
            View All
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        
        <div className="space-y-3">
          {mockGameHistory.slice(0, 3).map((game, idx) => (
            <motion.div
              key={game.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.1 }}
              className="p-4 rounded-[18px] ios-blur-thin border border-white/10 shadow-lg"
              style={{ background: 'rgba(255, 255, 255, 0.05)' }}
            >
              <div className="flex items-start justify-between mb-3">
                <div>
                  <div className="text-sm font-bold text-[#BF5AF2] tracking-wide">#{game.roomCode}</div>
                  <div className="text-xs text-white/50 font-medium mt-0.5">{game.date}</div>
                </div>
                <div className="text-right">
                  <div className="text-sm font-semibold text-white">${game.betAmount}</div>
                  <div className="text-xs text-[#30D158] font-medium mt-0.5">{game.winner}</div>
                </div>
              </div>
              <div className="flex gap-2 flex-wrap">
                {game.players.slice(0, 4).map((player, idx) => (
                  <div 
                    key={idx}
                    className={`px-3 py-1.5 rounded-lg text-xs font-semibold ${
                      player.won 
                        ? 'bg-[#30D158]/20 text-[#30D158] border border-[#30D158]/30' 
                        : 'bg-white/5 text-white/60 border border-white/10'
                    }`}
                  >
                    {player.name.split(' ')[0]}
                  </div>
                ))}
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Full History Dialog */}
      <Dialog open={showHistoryDialog} onOpenChange={setShowHistoryDialog}>
        <DialogContent className="ios-blur-thick border-white/10 rounded-[24px] shadow-2xl max-w-xl max-h-[80vh] overflow-y-auto"
                       style={{ background: 'rgba(28, 28, 30, 0.95)' }}>
          <DialogHeader>
            <DialogTitle className="text-white flex items-center gap-2 text-2xl font-bold tracking-tight">
              <History className="w-6 h-6" />
              Game History
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-3 py-4">
            {mockGameHistory.map((game) => (
              <div key={game.id} className="p-4 rounded-[16px] ios-blur-thin border border-white/10"
                   style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <div className="font-bold text-[#BF5AF2]">#{game.roomCode}</div>
                    <div className="text-sm text-white/50 mt-0.5">{game.date}</div>
                  </div>
                  <div className="text-right">
                    <div className="font-semibold text-white">${game.betAmount}</div>
                    <div className="text-sm text-[#30D158]">{game.winner}</div>
                  </div>
                </div>
                <div className="space-y-2">
                  {game.players.map((player, idx) => (
                    <div key={idx} className="flex items-center justify-between p-2 rounded-lg ios-blur-ultra-thin">
                      <span className={`text-sm font-semibold ${player.won ? 'text-[#30D158]' : 'text-white/80'}`}>
                        {player.name}
                      </span>
                      <span className={`text-sm ${player.won ? 'text-[#30D158]' : 'text-white/50'}`}>
                        {player.score} pts
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
