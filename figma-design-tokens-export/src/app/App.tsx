import { useState, useEffect } from 'react';
import { ThemeProvider } from 'next-themes';
import { Toaster } from 'sonner';
import LoginScreen from '@/app/components/LoginScreen';
import MainApp from '@/app/components/MainApp';

// Mock user type
export type User = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  avatar: string;
};

export default function App() {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in (from localStorage)
    const savedUser = localStorage.getItem('rummy_user');
    if (savedUser) {
      setCurrentUser(JSON.parse(savedUser));
    }
    setIsLoading(false);
  }, []);

  const handleLogin = (user: User) => {
    setCurrentUser(user);
    localStorage.setItem('rummy_user', JSON.stringify(user));
  };

  const handleLogout = () => {
    setCurrentUser(null);
    localStorage.removeItem('rummy_user');
    localStorage.removeItem('rummy_current_room');
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-violet-950 via-indigo-950 to-purple-950">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-violet-500 border-t-transparent"></div>
      </div>
    );
  }

  return (
    <ThemeProvider attribute="class" defaultTheme="dark">
      <Toaster position="top-center" richColors />
      {!currentUser ? (
        <LoginScreen onLogin={handleLogin} />
      ) : (
        <MainApp currentUser={currentUser} onLogout={handleLogout} />
      )}
    </ThemeProvider>
  );
}