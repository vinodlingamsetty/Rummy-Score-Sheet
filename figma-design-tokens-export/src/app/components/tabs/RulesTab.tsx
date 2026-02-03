import { motion } from 'motion/react';
import { Users, Layers, Trophy, AlertCircle } from 'lucide-react';

export default function RulesTab() {
  const deckRecommendations = [
    { players: '2 players', decks: '1-2 decks' },
    { players: '2-4 players', decks: '2 decks' },
    { players: '4-6 players', decks: '2 decks' },
    { players: '5-8 players', decks: '3 decks' },
    { players: '7+ players', decks: '3 decks' },
  ];

  const rules = [
    {
      icon: Users,
      title: 'Maximum Players',
      description: 'Up to 10 players can participate in a game. Beyond that, it becomes impractical for in-person or real-time play.',
      color: '#BF5AF2',
    },
    {
      icon: Layers,
      title: 'Deck Composition',
      description: 'Each deck contains 52 cards plus one joker. The number of decks varies based on player count.',
      color: '#5E5CE6',
    },
    {
      icon: Trophy,
      title: 'Winning Conditions',
      description: 'The last player below the game point limit wins the total prize pool. The moderator may also end the game early if needed.',
      color: '#FFD60A',
    },
    {
      icon: AlertCircle,
      title: 'Scoring Rules',
      description: 'When a player reaches the point limit, they can no longer add scores. Their input becomes disabled and they are out of the game.',
      color: '#FF453A',
    },
  ];

  const gameFlowSteps = [
    {
      number: 1,
      title: 'Create or Join Room',
      description: 'Moderator creates room with point limit and bet amount. Other players join using room code.',
    },
    {
      number: 2,
      title: 'Room Lobby',
      description: 'All players mark themselves as ready. Moderator starts the game when everyone is ready.',
    },
    {
      number: 3,
      title: 'Score Tracking',
      description: 'Players submit scores each round. Any player can submit, but only moderator can edit existing scores.',
    },
    {
      number: 4,
      title: 'Game End',
      description: 'Game ends when only one player is below the point limit. Winner takes the entire prize pool!',
    },
  ];

  return (
    <div className="min-h-screen px-4 pb-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-4xl font-bold text-white mb-1 tracking-tight">Game Rules</h1>
        <p className="text-lg text-white/60 font-medium">How to play and win at Rummy</p>
      </motion.div>

      {/* Key Rules */}
      <div className="space-y-3 mb-6">
        {rules.map((rule, index) => {
          const Icon = rule.icon;
          return (
            <motion.div
              key={index}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.05 }}
              className="p-5 rounded-[20px] ios-blur-thin border border-white/10 shadow-lg"
              style={{ background: 'rgba(255, 255, 255, 0.05)' }}
            >
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-[14px] flex items-center justify-center flex-shrink-0"
                     style={{ background: `${rule.color}20` }}>
                  <Icon className="w-6 h-6" style={{ color: rule.color }} strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <h3 className="text-lg font-bold text-white mb-1.5 tracking-tight">{rule.title}</h3>
                  <p className="text-white/60 text-sm leading-relaxed font-medium">{rule.description}</p>
                </div>
              </div>
            </motion.div>
          );
        })}
      </div>

      {/* Deck Recommendations */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-white mb-3 px-1 tracking-tight">Deck Recommendations</h2>
        <div className="p-5 rounded-[20px] ios-blur-thin border border-white/10 shadow-lg"
             style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
          <div className="space-y-2">
            {deckRecommendations.map((rec, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-3.5 rounded-[14px] ios-blur-ultra-thin border border-white/5"
              >
                <span className="text-white font-semibold text-base">{rec.players}</span>
                <span className="text-[#BF5AF2] font-bold text-base">{rec.decks}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Game Flow */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-white mb-3 px-1 tracking-tight">Game Flow</h2>
        <div className="space-y-2.5">
          {gameFlowSteps.map((step, index) => (
            <div key={index} className="p-4 rounded-[20px] ios-blur-thin border border-white/10 shadow-lg"
                 style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
              <div className="flex items-start gap-3 mb-2">
                <div className="w-8 h-8 rounded-full flex items-center justify-center font-bold text-white flex-shrink-0"
                     style={{ background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)' }}>
                  {step.number}
                </div>
                <h3 className="font-bold text-white text-base pt-0.5 tracking-tight">{step.title}</h3>
              </div>
              <p className="text-sm text-white/60 ml-11 leading-relaxed font-medium">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Additional Info */}
      <div className="p-5 rounded-[20px] ios-blur-thin border shadow-lg"
           style={{ 
             background: 'rgba(139, 92, 246, 0.1)',
             borderColor: 'rgba(139, 92, 246, 0.3)',
           }}>
        <h3 className="font-bold text-white mb-2 text-lg tracking-tight">Friend System</h3>
        <p className="text-sm text-white/70 leading-relaxed font-medium">
          Players who join the same room automatically become friends. Balances are automatically updated 
          when games finish. You can also manually update balances and settle payments through the Friends tab.
        </p>
      </div>
    </div>
  );
}
