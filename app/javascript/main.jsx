// Entry point for the build script in your package.json
import '@hotwired/turbo-rails';
import React from 'react';
import { render } from 'react-dom';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import App from './App';
import Signup from './components/users/Signup';
import SignIn from './components/users/SignIn';
import AuthProvider from './contexts/auth/AuthProvider';
import Profile from './components/users/Profile';
import Room from './components/rooms/Room';
import Rooms from './components/rooms/Rooms';
import HomePage from './components/home_page/HomePage';

const queryClient = new QueryClient();

const root = (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<App />}>
            <Route index element={<HomePage />} />
            <Route path="/signup" element={<Signup />} />
            <Route path="/signin" element={<SignIn />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="/rooms" element={<Rooms />} />
            <Route path="/rooms/:friendlyId" element={<Room />} />
            <Route path="*" element={<h1 className="text-center">404</h1>} />
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  </QueryClientProvider>
);

const rootElement = document.getElementById('root');
render(root, rootElement);
