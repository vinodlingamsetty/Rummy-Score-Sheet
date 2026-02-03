import { useState } from 'react';
import { motion } from 'motion/react';
import { Search, UserPlus, DollarSign, Trash2, Check, X, ChevronRight } from 'lucide-react';
import { Input } from '@/app/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/app/components/ui/dialog';
import { toast } from 'sonner';
import type { User } from '@/app/App';
import type { Friend } from '@/app/components/MainApp';

interface FriendsTabProps {
  currentUser: User;
}

const mockFriends: Friend[] = [
  { id: '1', firstName: 'Jane', lastName: 'Smith', avatar: '👩', balance: 25, isPending: false },
  { id: '2', firstName: 'Mike', lastName: 'Johnson', avatar: '👨', balance: -15, isPending: false },
  { id: '3', firstName: 'Sarah', lastName: 'Williams', avatar: '👧', balance: 0, isPending: false },
  { id: '4', firstName: 'Alex', lastName: 'Brown', avatar: '🧑', balance: 10, isPending: true },
];

export default function FriendsTab({ currentUser }: FriendsTabProps) {
  const [friends, setFriends] = useState<Friend[]>(mockFriends);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFriend, setSelectedFriend] = useState<Friend | null>(null);
  const [showDetailDialog, setShowDetailDialog] = useState(false);
  const [balanceAdjustment, setBalanceAdjustment] = useState('');

  const filteredFriends = friends.filter(friend => 
    `${friend.firstName} ${friend.lastName}`.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const pendingRequests = friends.filter(f => f.isPending);
  const activeFriends = friends.filter(f => !f.isPending);

  const handleAcceptRequest = (friendId: string) => {
    setFriends(friends.map(f => 
      f.id === friendId ? { ...f, isPending: false } : f
    ));
    toast.success('Friend request accepted!');
  };

  const handleRejectRequest = (friendId: string) => {
    setFriends(friends.filter(f => f.id !== friendId));
    toast.info('Friend request rejected');
  };

  const handleRemoveFriend = () => {
    if (selectedFriend) {
      setFriends(friends.filter(f => f.id !== selectedFriend.id));
      setShowDetailDialog(false);
      setSelectedFriend(null);
      toast.info('Friend removed');
    }
  };

  const handleUpdateBalance = () => {
    if (selectedFriend && balanceAdjustment) {
      const adjustment = parseFloat(balanceAdjustment);
      setFriends(friends.map(f => 
        f.id === selectedFriend.id 
          ? { ...f, balance: f.balance + adjustment }
          : f
      ));
      setBalanceAdjustment('');
      setShowDetailDialog(false);
      setSelectedFriend(null);
      toast.success('Balance updated! Waiting for approval...');
    }
  };

  const handleSettleInCash = () => {
    if (selectedFriend) {
      setFriends(friends.map(f => 
        f.id === selectedFriend.id 
          ? { ...f, balance: 0 }
          : f
      ));
      setShowDetailDialog(false);
      setSelectedFriend(null);
      toast.success('Marked as settled in cash!');
    }
  };

  const openFriendDetail = (friend: Friend) => {
    setSelectedFriend(friend);
    setShowDetailDialog(true);
  };

  return (
    <div className="min-h-screen px-4 pb-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-4xl font-bold text-white mb-1 tracking-tight">Friends</h1>
        <p className="text-lg text-white/60 font-medium">Manage your gaming buddies</p>
      </motion.div>

      {/* Search Bar */}
      <div className="mb-6 relative">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40 pointer-events-none" />
        <Input
          type="text"
          placeholder="Search friends..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pl-12 h-12 rounded-[14px] ios-blur-thin bg-white/5 border-white/10 text-white placeholder:text-white/40 text-base"
        />
      </div>

      {/* Pending Requests */}
      {pendingRequests.length > 0 && (
        <div className="mb-6">
          <div className="flex items-center gap-2 mb-3 px-1">
            <UserPlus className="w-5 h-5 text-[#0A84FF]" />
            <h2 className="text-xl font-bold text-white tracking-tight">
              Pending Requests ({pendingRequests.length})
            </h2>
          </div>
          <div className="space-y-2">
            {pendingRequests.map((friend, idx) => (
              <motion.div
                key={friend.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: idx * 0.05 }}
                className="flex items-center justify-between p-4 rounded-[16px] ios-blur-thin border border-[#0A84FF]/30 shadow-lg"
                style={{ background: 'rgba(10, 132, 255, 0.1)' }}
              >
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full flex items-center justify-center text-2xl"
                       style={{ 
                         background: 'linear-gradient(135deg, rgba(10, 132, 255, 0.2) 0%, rgba(94, 92, 230, 0.2) 100%)',
                       }}>
                    {friend.avatar}
                  </div>
                  <div>
                    <div className="font-semibold text-white text-base">
                      {friend.firstName} {friend.lastName}
                    </div>
                    <div className="text-sm text-white/50 font-medium">Wants to be friends</div>
                  </div>
                </div>
                <div className="flex gap-2">
                  <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => handleAcceptRequest(friend.id)}
                    className="p-2.5 rounded-[12px] bg-[#30D158]/20 border border-[#30D158]/30"
                  >
                    <Check className="w-5 h-5 text-[#30D158]" strokeWidth={2.5} />
                  </motion.button>
                  <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => handleRejectRequest(friend.id)}
                    className="p-2.5 rounded-[12px] bg-red-500/20 border border-red-500/30"
                  >
                    <X className="w-5 h-5 text-red-400" strokeWidth={2.5} />
                  </motion.button>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      )}

      {/* Friends List */}
      <div className="mb-6">
        <h2 className="text-xl font-bold text-white mb-3 px-1 tracking-tight">
          All Friends ({activeFriends.length})
        </h2>
        <div className="space-y-2">
          {filteredFriends.filter(f => !f.isPending).map((friend, idx) => (
            <motion.button
              key={friend.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.05 }}
              onClick={() => openFriendDetail(friend)}
              whileTap={{ scale: 0.98 }}
              className="w-full flex items-center justify-between p-4 rounded-[16px] ios-blur-thin border border-white/10 shadow-lg text-left"
              style={{ background: 'rgba(255, 255, 255, 0.05)' }}
            >
              <div className="flex items-center gap-3 flex-1 min-w-0">
                <div className="w-12 h-12 rounded-full flex items-center justify-center text-2xl flex-shrink-0"
                     style={{ 
                       background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(99, 102, 241, 0.2) 100%)',
                     }}>
                  {friend.avatar}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="font-semibold text-white text-base truncate">
                    {friend.firstName} {friend.lastName}
                  </div>
                  {friend.balance !== 0 && (
                    <div className="flex items-center gap-1 text-sm mt-0.5">
                      <DollarSign className="w-3.5 h-3.5" />
                      {friend.balance > 0 ? (
                        <span className="text-[#30D158] font-medium">
                          They owe ${Math.abs(friend.balance)}
                        </span>
                      ) : (
                        <span className="text-red-400 font-medium">
                          You owe ${Math.abs(friend.balance)}
                        </span>
                      )}
                    </div>
                  )}
                </div>
              </div>
              <div className="flex items-center gap-2 flex-shrink-0">
                {friend.balance !== 0 && (
                  <div className={`text-xl font-bold ${
                    friend.balance > 0 ? 'text-[#30D158]' : 'text-red-400'
                  }`}>
                    ${Math.abs(friend.balance)}
                  </div>
                )}
                <ChevronRight className="w-5 h-5 text-white/30" />
              </div>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Friend Detail Dialog */}
      <Dialog open={showDetailDialog} onOpenChange={setShowDetailDialog}>
        <DialogContent className="ios-blur-thick border-white/10 rounded-[24px] shadow-2xl"
                       style={{ background: 'rgba(28, 28, 30, 0.95)' }}>
          <DialogHeader>
            <DialogTitle className="text-white flex items-center gap-3 text-xl font-bold tracking-tight">
              <div className="w-12 h-12 rounded-full flex items-center justify-center text-2xl"
                   style={{ 
                     background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(99, 102, 241, 0.2) 100%)',
                   }}>
                {selectedFriend?.avatar}
              </div>
              {selectedFriend?.firstName} {selectedFriend?.lastName}
            </DialogTitle>
          </DialogHeader>
          
          {selectedFriend && (
            <div className="space-y-4 py-4">
              {/* Current Balance */}
              <div className="p-6 rounded-[20px] ios-blur-thin border border-white/10 text-center"
                   style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
                <div className="text-sm text-white/60 font-medium mb-2">Current Balance</div>
                <div className={`text-5xl font-bold ${
                  selectedFriend.balance > 0 
                    ? 'text-[#30D158]' 
                    : selectedFriend.balance < 0 
                      ? 'text-red-400' 
                      : 'text-white/40'
                }`}>
                  ${Math.abs(selectedFriend.balance)}
                </div>
                {selectedFriend.balance > 0 && (
                  <div className="text-sm text-[#30D158] font-medium mt-2">They owe you</div>
                )}
                {selectedFriend.balance < 0 && (
                  <div className="text-sm text-red-400 font-medium mt-2">You owe them</div>
                )}
                {selectedFriend.balance === 0 && (
                  <div className="text-sm text-white/50 font-medium mt-2">All settled</div>
                )}
              </div>

              {/* Update Balance */}
              <div>
                <label className="text-sm text-white/70 font-semibold mb-2 block">Adjust Balance</label>
                <Input
                  type="number"
                  placeholder="Enter amount (+ or -)"
                  value={balanceAdjustment}
                  onChange={(e) => setBalanceAdjustment(e.target.value)}
                  className="ios-blur-thin bg-white/5 border-white/10 text-white h-14 rounded-[14px] text-center text-lg"
                />
                <div className="text-xs text-white/40 mt-2 text-center font-medium">
                  Positive = they owe you • Negative = you owe them
                </div>
              </div>

              {/* Actions */}
              <div className="space-y-2.5 pt-2">
                <motion.button
                  whileTap={{ scale: 0.97 }}
                  onClick={handleUpdateBalance}
                  disabled={!balanceAdjustment}
                  className="w-full h-14 rounded-[14px] text-white text-lg font-semibold disabled:opacity-30 shadow-lg"
                  style={{
                    background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
                  }}
                >
                  Update Balance
                </motion.button>
                
                {selectedFriend.balance !== 0 && (
                  <motion.button
                    whileTap={{ scale: 0.97 }}
                    onClick={handleSettleInCash}
                    className="w-full h-14 rounded-[14px] text-white text-lg font-semibold shadow-lg"
                    style={{
                      background: 'linear-gradient(135deg, #30D158 0%, #34C759 100%)',
                    }}
                  >
                    Settle in Cash
                  </motion.button>
                )}

                <motion.button
                  whileTap={{ scale: 0.97 }}
                  onClick={handleRemoveFriend}
                  className="w-full h-12 rounded-[14px] ios-blur-thin bg-red-500/20 text-red-400 border border-red-500/30 font-semibold flex items-center justify-center gap-2"
                >
                  <Trash2 className="w-4 h-4" />
                  Remove Friend
                </motion.button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
