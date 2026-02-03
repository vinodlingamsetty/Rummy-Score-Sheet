import { useState } from 'react';
import { motion } from 'motion/react';
import { LogOut, Bell, Volume2, Palette, Edit2, Save, ChevronRight } from 'lucide-react';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Switch } from '@/app/components/ui/switch';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/app/components/ui/dialog';
import { toast } from 'sonner';
import type { User as UserType } from '@/app/App';

interface ProfileTabProps {
  currentUser: UserType;
  onLogout: () => void;
}

const avatarOptions = ['👤', '👨', '👩', '🧑', '👧', '👦', '🧔', '👱', '👨‍💼', '👩‍💼', '🧑‍💻', '👨‍🎓'];

export default function ProfileTab({ currentUser, onLogout }: ProfileTabProps) {
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [firstName, setFirstName] = useState(currentUser.firstName);
  const [lastName, setLastName] = useState(currentUser.lastName);
  const [selectedAvatar, setSelectedAvatar] = useState(currentUser.avatar);
  
  const [notifications, setNotifications] = useState(true);
  const [sound, setSound] = useState(true);
  const [vibration, setVibration] = useState(true);
  const [darkMode, setDarkMode] = useState(true);

  const handleSaveProfile = () => {
    const updatedUser = {
      ...currentUser,
      firstName,
      lastName,
      avatar: selectedAvatar,
    };
    
    localStorage.setItem('rummy_user', JSON.stringify(updatedUser));
    setIsEditingProfile(false);
    toast.success('Profile updated!');
  };

  const handleLogout = () => {
    if (window.confirm('Are you sure you want to logout?')) {
      onLogout();
    }
  };

  return (
    <div className="min-h-screen px-4 pb-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-4xl font-bold text-white mb-1 tracking-tight">Profile</h1>
        <p className="text-lg text-white/60 font-medium">Manage your account</p>
      </motion.div>

      {/* Profile Card */}
      <div className="mb-6">
        <div className="p-6 rounded-[24px] ios-blur-regular border border-white/10 shadow-xl"
             style={{ background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.15) 0%, rgba(99, 102, 241, 0.15) 100%)' }}>
          <div className="flex items-start justify-between mb-6">
            <div className="flex items-center gap-4">
              <div className="w-20 h-20 rounded-full flex items-center justify-center text-4xl"
                   style={{ 
                     background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.3) 0%, rgba(99, 102, 241, 0.3) 100%)',
                   }}>
                {selectedAvatar}
              </div>
              <div>
                <h2 className="text-2xl font-bold text-white tracking-tight">
                  {firstName} {lastName}
                </h2>
                <p className="text-white/60 font-medium">{currentUser.email}</p>
              </div>
            </div>
            
            <Dialog open={isEditingProfile} onOpenChange={setIsEditingProfile}>
              <DialogTrigger asChild>
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  className="px-4 py-2.5 rounded-[14px] text-white font-semibold shadow-lg flex items-center gap-2"
                  style={{
                    background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
                  }}
                >
                  <Edit2 className="w-4 h-4" />
                  Edit
                </motion.button>
              </DialogTrigger>
              
              <DialogContent className="ios-blur-thick border-white/10 rounded-[24px] shadow-2xl"
                             style={{ background: 'rgba(28, 28, 30, 0.95)' }}>
                <DialogHeader>
                  <DialogTitle className="text-white text-2xl font-bold tracking-tight">Edit Profile</DialogTitle>
                </DialogHeader>
                
                <div className="space-y-5 py-4">
                  <div>
                    <Label className="text-white/80 text-base font-semibold mb-2 block">First Name</Label>
                    <Input
                      value={firstName}
                      onChange={(e) => setFirstName(e.target.value)}
                      className="ios-blur-thin bg-white/5 border-white/10 text-white text-lg h-14 rounded-[14px] px-4"
                    />
                  </div>
                  
                  <div>
                    <Label className="text-white/80 text-base font-semibold mb-2 block">Last Name</Label>
                    <Input
                      value={lastName}
                      onChange={(e) => setLastName(e.target.value)}
                      className="ios-blur-thin bg-white/5 border-white/10 text-white text-lg h-14 rounded-[14px] px-4"
                    />
                  </div>

                  <div>
                    <Label className="text-white/80 text-base font-semibold mb-3 block">Choose Avatar</Label>
                    <div className="grid grid-cols-6 gap-2">
                      {avatarOptions.map((avatar) => (
                        <motion.button
                          key={avatar}
                          whileTap={{ scale: 0.9 }}
                          onClick={() => setSelectedAvatar(avatar)}
                          className={`w-14 h-14 rounded-[14px] flex items-center justify-center text-2xl transition-all ${
                            selectedAvatar === avatar
                              ? 'shadow-lg'
                              : 'ios-blur-ultra-thin border border-white/10'
                          }`}
                          style={selectedAvatar === avatar ? {
                            background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.3) 0%, rgba(99, 102, 241, 0.3) 100%)',
                            border: '2px solid rgba(139, 92, 246, 0.5)',
                          } : {}}
                        >
                          {avatar}
                        </motion.button>
                      ))}
                    </div>
                  </div>

                  <motion.button
                    whileTap={{ scale: 0.97 }}
                    onClick={handleSaveProfile}
                    className="w-full h-14 rounded-[14px] text-white text-lg font-semibold shadow-lg flex items-center justify-center gap-2"
                    style={{
                      background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
                    }}
                  >
                    <Save className="w-5 h-5" />
                    Save Changes
                  </motion.button>
                </div>
              </DialogContent>
            </Dialog>
          </div>

          <div className="grid grid-cols-3 gap-3 pt-5 border-t border-white/10">
            <div className="text-center p-3 rounded-[14px] ios-blur-ultra-thin">
              <div className="text-3xl font-bold text-[#BF5AF2]">12</div>
              <div className="text-xs text-white/50 font-medium mt-1">Games</div>
            </div>
            <div className="text-center p-3 rounded-[14px] ios-blur-ultra-thin">
              <div className="text-3xl font-bold text-[#30D158]">5</div>
              <div className="text-xs text-white/50 font-medium mt-1">Wins</div>
            </div>
            <div className="text-center p-3 rounded-[14px] ios-blur-ultra-thin">
              <div className="text-3xl font-bold text-[#FFD60A]">$150</div>
              <div className="text-xs text-white/50 font-medium mt-1">Total</div>
            </div>
          </div>
        </div>
      </div>

      {/* App Settings */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-white mb-3 px-1 tracking-tight">App Settings</h2>
        
        <div className="space-y-2">
          <div className="p-4 rounded-[18px] ios-blur-thin border border-white/10 shadow-lg"
               style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3 flex-1">
                <div className="w-10 h-10 rounded-[12px] flex items-center justify-center"
                     style={{ background: 'rgba(255, 69, 58, 0.2)' }}>
                  <Bell className="w-5 h-5 text-[#FF453A]" strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-white text-base">Push Notifications</div>
                  <div className="text-sm text-white/50 font-medium">Get notified about updates</div>
                </div>
              </div>
              <Switch
                checked={notifications}
                onCheckedChange={(checked) => {
                  setNotifications(checked);
                  toast.success(checked ? 'Notifications enabled' : 'Notifications disabled');
                }}
              />
            </div>
          </div>

          <div className="p-4 rounded-[18px] ios-blur-thin border border-white/10 shadow-lg"
               style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3 flex-1">
                <div className="w-10 h-10 rounded-[12px] flex items-center justify-center"
                     style={{ background: 'rgba(10, 132, 255, 0.2)' }}>
                  <Volume2 className="w-5 h-5 text-[#0A84FF]" strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-white text-base">Sound Effects</div>
                  <div className="text-sm text-white/50 font-medium">Play sounds for actions</div>
                </div>
              </div>
              <Switch
                checked={sound}
                onCheckedChange={(checked) => {
                  setSound(checked);
                  toast.success(checked ? 'Sound enabled' : 'Sound disabled');
                }}
              />
            </div>
          </div>

          <div className="p-4 rounded-[18px] ios-blur-thin border border-white/10 shadow-lg"
               style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3 flex-1">
                <div className="w-10 h-10 rounded-[12px] flex items-center justify-center"
                     style={{ background: 'rgba(94, 92, 230, 0.2)' }}>
                  <Volume2 className="w-5 h-5 text-[#5E5CE6]" strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-white text-base">Vibration</div>
                  <div className="text-sm text-white/50 font-medium">Haptic feedback</div>
                </div>
              </div>
              <Switch
                checked={vibration}
                onCheckedChange={(checked) => {
                  setVibration(checked);
                  toast.success(checked ? 'Vibration enabled' : 'Vibration disabled');
                }}
              />
            </div>
          </div>

          <div className="p-4 rounded-[18px] ios-blur-thin border border-white/10 shadow-lg"
               style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3 flex-1">
                <div className="w-10 h-10 rounded-[12px] flex items-center justify-center"
                     style={{ background: 'rgba(191, 90, 242, 0.2)' }}>
                  <Palette className="w-5 h-5 text-[#BF5AF2]" strokeWidth={2.5} />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-white text-base">Dark Mode</div>
                  <div className="text-sm text-white/50 font-medium">Use dark theme</div>
                </div>
              </div>
              <Switch
                checked={darkMode}
                onCheckedChange={(checked) => {
                  setDarkMode(checked);
                  toast.info(checked ? 'Dark mode' : 'Light mode (Demo)');
                }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Logout Button */}
      <motion.button
        whileTap={{ scale: 0.97 }}
        onClick={handleLogout}
        className="w-full h-14 rounded-[14px] ios-blur-thin bg-red-500/20 text-red-400 border border-red-500/30 font-semibold text-lg flex items-center justify-center gap-2 shadow-lg"
      >
        <LogOut className="w-5 h-5" />
        Logout
      </motion.button>

      {/* App Info */}
      <div className="mt-6 text-center">
        <p className="text-sm text-white/40 font-medium">Rummy Score Tracker</p>
        <p className="text-xs text-white/30 font-medium mt-1">Version 1.0.0 • iOS 26 Design</p>
      </div>
    </div>
  );
}
