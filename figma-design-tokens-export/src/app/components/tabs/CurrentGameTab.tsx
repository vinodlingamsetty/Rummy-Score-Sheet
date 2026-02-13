import { useState } from 'react';
import { motion } from 'motion/react';
import { Users, CheckCircle, XCircle, Play, LogOut, Edit, Save, Trophy, Crown } from 'lucide-react';
import { Input } from '@/app/components/ui/input';
import { toast } from 'sonner';
import type { User } from '@/app/App';
import type { GameRoom } from '@/app/components/MainApp';

interface CurrentGameTabProps {
  currentUser: User;
  currentRoom: GameRoom | null;
  setCurrentRoom: (room: GameRoom | null) => void;
  setActiveTab: (tab: 'home' | 'game' | 'friends' | 'rules' | 'profile') => void;
}

export default function CurrentGameTab({ currentUser, currentRoom, setCurrentRoom, setActiveTab }: CurrentGameTabProps) {
  const [selectedRound, setSelectedRound] = useState<number>(currentRoom?.currentRound || 1);
  const [isEditing, setIsEditing] = useState(false);
  const [roundScores, setRoundScores] = useState<Record<string, string>>({});

  // If no room, show empty state
  if (!currentRoom) {
    return (
      <div className="min-h-screen px-4 pb-6 flex items-center justify-center">
        <div className="text-center">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: 'spring', stiffness: 200, damping: 15 }}
            className="mb-6"
          >
            <Trophy className="w-24 h-24 mx-auto text-white/30" />
          </motion.div>
          <h2 className="text-2xl font-bold text-white mb-3 tracking-tight">No Active Game</h2>
          <p className="text-white/60 mb-6 font-medium">Create or join a room to start playing</p>
          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setActiveTab('home')}
            className="px-8 py-3.5 rounded-[14px] text-white text-lg font-semibold shadow-lg"
            style={{
              background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
            }}
          >
            Go to Home
          </motion.button>
        </div>
      </div>
    );
  }

  const isModerator = currentRoom.moderatorId === currentUser.id;
  const maxRounds = 15;

  const getTotalScore = (playerId: string): number => {
    const scores = currentRoom.scores[playerId] || [];
    return scores.reduce((sum, score) => sum + score, 0);
  };

  const hasReachedLimit = (playerId: string): boolean => {
    return getTotalScore(playerId) >= currentRoom.pointLimit;
  };

  const handleToggleReady = () => {
    const updatedPlayers = currentRoom.players.map(p => 
      p.id === currentUser.id ? { ...p, isReady: !p.isReady } : p
    );
    setCurrentRoom({ ...currentRoom, players: updatedPlayers });
    toast.success(updatedPlayers.find(p => p.id === currentUser.id)?.isReady ? 'Ready!' : 'Not ready');
  };

  const handleStartGame = () => {
    if (!currentRoom.players.every(p => p.isReady)) {
      toast.error('All players must be ready!');
      return;
    }
    
    const initialScores: Record<string, number[]> = {};
    currentRoom.players.forEach(p => {
      initialScores[p.id] = [];
    });
    
    setCurrentRoom({ 
      ...currentRoom, 
      status: 'playing',
      scores: initialScores,
    });
    toast.success('Game started!');
  };

  const handleSubmitScores = () => {
    const updatedScores = { ...currentRoom.scores };
    let hasChanges = false;

    currentRoom.players.forEach(player => {
      const scoreInput = roundScores[player.id];
      if (scoreInput && !hasReachedLimit(player.id)) {
        const score = parseInt(scoreInput) || 0;
        if (!updatedScores[player.id]) {
          updatedScores[player.id] = [];
        }
        
        while (updatedScores[player.id].length < selectedRound) {
          updatedScores[player.id].push(0);
        }
        
        if (updatedScores[player.id].length === selectedRound - 1) {
          updatedScores[player.id].push(score);
          hasChanges = true;
        } else {
          updatedScores[player.id][selectedRound - 1] = score;
          hasChanges = true;
        }
      }
    });

    if (hasChanges) {
      setCurrentRoom({ ...currentRoom, scores: updatedScores, currentRound: selectedRound + 1 });
      setRoundScores({});
      setSelectedRound(selectedRound + 1);
      setIsEditing(false);
      toast.success('Scores saved!');
      
      const activePlayers = currentRoom.players.filter(p => !hasReachedLimit(p.id));
      if (activePlayers.length === 1) {
        toast.success(`🎉 ${activePlayers[0].firstName} ${activePlayers[0].lastName} wins!`);
      }
    }
  };

  const handleLeaveRoom = () => {
    setCurrentRoom(null);
    setActiveTab('home');
    toast.info('Left the room');
  };

  const handleEndGame = () => {
    setCurrentRoom({ ...currentRoom, status: 'finished' });
    toast.success('Game ended by moderator');
  };

  // Lobby View
  if (currentRoom.status === 'lobby') {
    return (
      <div className="min-h-screen px-4 pb-6">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-6"
        >
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-3xl font-bold text-white tracking-tight">Room Lobby</h1>
              <p className="text-lg text-white/60 font-medium">Code: {currentRoom.code}</p>
            </div>
            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={handleLeaveRoom}
              className="px-4 py-2.5 rounded-[14px] ios-blur-thin bg-red-500/20 text-red-400 border border-red-500/30 font-semibold"
            >
              Leave
            </motion.button>
          </div>

          <div className="p-5 rounded-[20px] ios-blur-regular border border-white/10 mb-6 shadow-lg"
               style={{ background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.15) 0%, rgba(99, 102, 241, 0.15) 100%)' }}>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <div className="text-sm text-white/60 font-medium mb-1">Point Limit</div>
                <div className="text-3xl font-bold text-[#BF5AF2]">{currentRoom.pointLimit}</div>
              </div>
              <div>
                <div className="text-sm text-white/60 font-medium mb-1">Bet Amount</div>
                <div className="text-3xl font-bold text-[#30D158]">${currentRoom.betAmount}</div>
              </div>
            </div>
          </div>
        </motion.div>

        <div className="mb-6">
          <div className="flex items-center gap-2 mb-4 px-1">
            <Users className="w-5 h-5 text-[#0A84FF]" />
            <h2 className="text-xl font-bold text-white tracking-tight">
              Players ({currentRoom.players.length}/10)
            </h2>
          </div>

          <div className="space-y-2">
            {currentRoom.players.map((player, idx) => (
              <motion.div
                key={player.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: idx * 0.05 }}
                className="flex items-center justify-between p-4 rounded-[16px] ios-blur-thin border border-white/10 shadow-lg"
                style={{ background: 'rgba(255, 255, 255, 0.05)' }}
              >
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full flex items-center justify-center text-2xl"
                       style={{ 
                         background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(99, 102, 241, 0.2) 100%)',
                       }}>
                    {player.avatar}
                  </div>
                  <div>
                    <div className="font-semibold text-white text-base">
                      {player.firstName} {player.lastName}
                    </div>
                    {player.id === currentRoom.moderatorId && (
                      <div className="flex items-center gap-1 mt-0.5">
                        <Crown className="w-3 h-3 text-[#FFD60A]" />
                        <span className="text-xs font-semibold text-[#FFD60A]">Moderator</span>
                      </div>
                    )}
                  </div>
                </div>
                {player.isReady ? (
                  <CheckCircle className="w-6 h-6 text-[#30D158]" strokeWidth={2.5} />
                ) : (
                  <XCircle className="w-6 h-6 text-white/30" strokeWidth={2.5} />
                )}
              </motion.div>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div className="space-y-2.5">
          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={handleToggleReady}
            className={`w-full h-14 rounded-[14px] text-lg font-semibold shadow-lg ${
              currentRoom.players.find(p => p.id === currentUser.id)?.isReady
                ? 'bg-white/10 text-white border border-white/20'
                : 'text-white'
            }`}
            style={!currentRoom.players.find(p => p.id === currentUser.id)?.isReady ? {
              background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
            } : {}}
          >
            {currentRoom.players.find(p => p.id === currentUser.id)?.isReady ? 'Not Ready' : 'Ready'}
          </motion.button>

          {isModerator && (
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={handleStartGame}
              disabled={!currentRoom.players.every(p => p.isReady)}
              className="w-full h-14 rounded-[14px] text-white text-lg font-semibold disabled:opacity-30 shadow-lg flex items-center justify-center gap-2"
              style={{
                background: 'linear-gradient(135deg, #30D158 0%, #34C759 100%)',
              }}
            >
              <Play className="w-5 h-5" />
              Start Game
            </motion.button>
          )}
        </div>
      </div>
    );
  }

  // Game Finished View
  if (currentRoom.status === 'finished') {
    const winner = currentRoom.players.find(p => !hasReachedLimit(p.id)) || 
                   currentRoom.players.reduce((min, p) => getTotalScore(p.id) < getTotalScore(min.id) ? p : min);
    
    return (
      <div className="min-h-screen px-4 pb-6">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center pt-8"
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: 'spring', stiffness: 200, damping: 15, delay: 0.2 }}
            className="mb-6"
          >
            <Trophy className="w-24 h-24 mx-auto text-[#FFD60A] drop-shadow-lg" />
          </motion.div>
          
          <h1 className="text-4xl font-bold text-white mb-6 tracking-tight">Game Over!</h1>
          
          <div className="p-6 rounded-[24px] ios-blur-regular border-2 mb-6 shadow-2xl"
               style={{ 
                 background: 'linear-gradient(135deg, rgba(255, 214, 10, 0.15) 0%, rgba(255, 204, 0, 0.15) 100%)',
                 borderColor: 'rgba(255, 214, 10, 0.3)',
               }}>
            <div className="text-3xl font-bold text-white mb-2">
              {winner.firstName} {winner.lastName}
            </div>
            <div className="text-xl text-[#FFD60A] font-semibold">
              Winner • {getTotalScore(winner.id)} points
            </div>
          </div>

          <div className="space-y-2 mb-6">
            <h3 className="text-lg font-semibold text-white/70 mb-3">Final Scores</h3>
            {currentRoom.players
              .sort((a, b) => getTotalScore(a.id) - getTotalScore(b.id))
              .map((player) => (
                <div
                  key={player.id}
                  className="flex justify-between p-4 rounded-[16px] ios-blur-thin border border-white/10"
                  style={{ background: 'rgba(255, 255, 255, 0.05)' }}
                >
                  <span className={`font-semibold ${player.id === winner.id ? 'text-[#30D158]' : 'text-white'}`}>
                    {player.firstName} {player.lastName}
                  </span>
                  <span className={player.id === winner.id ? 'text-[#30D158] font-bold' : 'text-white/60'}>
                    {getTotalScore(player.id)} pts
                  </span>
                </div>
              ))}
          </div>

          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => {
              setCurrentRoom(null);
              setActiveTab('home');
            }}
            className="w-full h-14 rounded-[14px] text-white text-lg font-semibold shadow-lg"
            style={{
              background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
            }}
          >
            Return to Home
          </motion.button>
        </motion.div>
      </div>
    );
  }

  // Playing View
  return (
    <div className="min-h-screen pb-6">
      {/* Sticky Header */}
      <div className="sticky top-0 z-20 ios-blur-thick border-b border-white/10 px-4 py-3 mb-4"
           style={{ 
             background: 'rgba(28, 28, 30, 0.85)',
             boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3)',
           }}>
        <div className="flex items-center justify-between">
          <div>
            <div className="text-sm text-white/60 font-medium">Room {currentRoom.code}</div>
            <div className="text-lg font-bold text-white">Target: {currentRoom.pointLimit}</div>
          </div>
          {isModerator && (
            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={handleEndGame}
              className="px-4 py-2 rounded-[12px] ios-blur-thin bg-red-500/20 text-red-400 border border-red-500/30 text-sm font-semibold"
            >
              End Game
            </motion.button>
          )}
        </div>
      </div>

      <div className="px-4">
        {/* Round Navigation */}
        <div className="mb-5 overflow-x-auto scrollbar-hide">
          <div className="flex gap-2 pb-2">
            {[...Array(maxRounds)].map((_, idx) => {
              const round = idx + 1;
              const hasScores = currentRoom.players.some(p => 
                currentRoom.scores[p.id]?.length >= round
              );
              
              return (
                <motion.button
                  key={round}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setSelectedRound(round)}
                  className={`px-4 py-2 rounded-[12px] whitespace-nowrap font-semibold text-sm transition-all ${
                    selectedRound === round
                      ? 'text-white shadow-lg'
                      : hasScores
                        ? 'bg-white/10 text-white/70 border border-white/10'
                        : 'bg-white/5 text-white/40 border border-white/5'
                  }`}
                  style={selectedRound === round ? {
                    background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
                  } : {}}
                >
                  R{round}
                </motion.button>
              );
            })}
            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => setSelectedRound(0)}
              className={`px-4 py-2 rounded-[12px] whitespace-nowrap font-semibold text-sm ${
                selectedRound === 0
                  ? 'text-white shadow-lg'
                  : 'bg-white/10 text-white/70 border border-white/10'
              }`}
              style={selectedRound === 0 ? {
                background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
              } : {}}
            >
              T
            </motion.button>
          </div>
        </div>

        {/* Scores Table */}
        <div className="space-y-2.5">
          {currentRoom.players
            .sort((a, b) => `${a.firstName} ${a.lastName}`.localeCompare(`${b.firstName} ${b.lastName}`))
            .map((player) => {
              const playerScores = currentRoom.scores[player.id] || [];
              const isDisabled = hasReachedLimit(player.id);
              const displayScore = selectedRound === 0 
                ? getTotalScore(player.id)
                : playerScores[selectedRound - 1] || 0;

              return (
                <div
                  key={player.id}
                  className={`flex items-center gap-3 p-3.5 rounded-[16px] ios-blur-thin border ${
                    isDisabled 
                      ? 'border-red-500/30 bg-red-500/5'
                      : 'border-white/10 bg-white/5'
                  } shadow-lg`}
                >
                  <div className="w-10 h-10 rounded-full flex items-center justify-center text-xl"
                       style={{ 
                         background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(99, 102, 241, 0.2) 100%)',
                       }}>
                    {player.avatar}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold text-white text-base truncate">
                      {player.firstName} {player.lastName}
                    </div>
                    <div className="text-sm text-white/50 font-medium">
                      Total: {getTotalScore(player.id)}{isDisabled && ' (Out)'}
                    </div>
                  </div>
                  {selectedRound === 0 ? (
                    <div className="text-2xl font-bold text-[#BF5AF2]">
                      {displayScore}
                    </div>
                  ) : (
                    <Input
                      type="number"
                      value={isEditing ? (roundScores[player.id] || '') : displayScore || ''}
                      onChange={(e) => setRoundScores({ ...roundScores, [player.id]: e.target.value })}
                      disabled={!isEditing || isDisabled}
                      className="w-20 text-center ios-blur-ultra-thin bg-white/5 border-white/20 text-white text-lg font-bold disabled:opacity-50 h-12 rounded-[12px]"
                      placeholder="0"
                    />
                  )}
                </div>
              );
            })}
        </div>

        {/* Action Buttons */}
        {selectedRound > 0 && (
          <div className="mt-5 flex gap-2.5">
            {!isEditing ? (
              <>
                {isModerator && (
                  <motion.button
                    whileTap={{ scale: 0.97 }}
                    onClick={() => setIsEditing(true)}
                    className="flex-1 h-14 rounded-[14px] text-white font-semibold ios-blur-thin bg-white/10 border border-white/20 flex items-center justify-center gap-2"
                  >
                    <Edit className="w-5 h-5" />
                    Edit
                  </motion.button>
                )}
                <motion.button
                  whileTap={{ scale: 0.97 }}
                  onClick={() => {
                    setIsEditing(true);
                    setRoundScores({});
                  }}
                  className="flex-1 h-14 rounded-[14px] text-white text-lg font-semibold shadow-lg"
                  style={{
                    background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
                  }}
                >
                  Add Scores
                </motion.button>
              </>
            ) : (
              <>
                <motion.button
                  whileTap={{ scale: 0.97 }}
                  onClick={() => {
                    setIsEditing(false);
                    setRoundScores({});
                  }}
                  className="flex-1 h-14 rounded-[14px] text-white font-semibold bg-white/10 border border-white/20"
                >
                  Cancel
                </motion.button>
                <motion.button
                  whileTap={{ scale: 0.97 }}
                  onClick={handleSubmitScores}
                  className="flex-1 h-14 rounded-[14px] text-white text-lg font-semibold shadow-lg flex items-center justify-center gap-2"
                  style={{
                    background: 'linear-gradient(135deg, #30D158 0%, #34C759 100%)',
                  }}
                >
                  <Save className="w-5 h-5" />
                  Submit
                </motion.button>
              </>
            )}
          </div>
        )}

        <motion.button
          whileTap={{ scale: 0.97 }}
          onClick={handleLeaveRoom}
          className="w-full mt-3 h-12 rounded-[14px] ios-blur-thin bg-red-500/20 text-red-400 border border-red-500/30 font-semibold flex items-center justify-center gap-2"
        >
          <LogOut className="w-5 h-5" />
          Leave Game
        </motion.button>
      </div>
    </div>
  );
}