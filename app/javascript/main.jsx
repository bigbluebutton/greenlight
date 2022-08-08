// Entry point for the build script in your package.json
import '@hotwired/turbo-rails';
import React from 'react';
import { render } from 'react-dom';
import {
  BrowserRouter as Router, Routes, Route, Navigate,
} from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import App from './App';
import Signup from './components/users/authentication/Signup';
import SignIn from './components/users/authentication/SignIn';
import AuthProvider from './contexts/auth/AuthProvider';
import Profile from './components/users/user/Profile';
import Room from './components/rooms/room/Room';
import Rooms from './components/rooms/Rooms';
import HomePage from './components/home/HomePage';
import RoomJoin from './components/rooms/room/RoomJoin';
import ForgetPassword from './components/users/FrogetPassword';
import ManageUsers from './components/admin/manage_users/ManageUsers';
import ServerRecordings from './components/admin/server_recordings/ServerRecordings';
import ServerRooms from './components/admin/server_rooms/ServerRooms';
import SiteSettings from './components/admin/site_settings/SiteSettings';
import RoomConfig from './components/admin/room_configuration/RoomConfig';
import Roles from './components/admin/roles/Roles';
import ResetPassword from './components/users/password_management/ResetPassword';
import EditUser from './components/admin/manage_users/EditUser';
import EditRole from './components/admin/roles/EditRole';

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
            <Route path="/forget_password" element={<ForgetPassword />} />
            <Route path="/reset_password/:token" element={<ResetPassword />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="/adminpanel" element={<Navigate to="/adminpanel/users" replace />} />
            <Route path="/adminpanel/users" element={<ManageUsers />} />
            <Route path="/adminpanel/edit_user/:userId" element={<EditUser />} />
            <Route path="/adminpanel/server-recordings" element={<ServerRecordings />} />
            <Route path="/adminpanel/server-rooms" element={<ServerRooms />} />
            <Route path="/adminpanel/room-configuration" element={<RoomConfig />} />
            <Route path="/adminpanel/site-settings" element={<SiteSettings />} />
            <Route path="/adminpanel/roles" element={<Roles />} />
            <Route path="/adminpanel/roles/edit/:roleId" element={<EditRole />} />
            <Route path="/rooms" element={<Rooms />} />
            <Route path="/rooms/:friendlyId" element={<Room />} />
            <Route path="/rooms/:friendlyId/join" element={<RoomJoin />} />
            <Route path="*" element={<h1 className="text-center">404</h1>} />
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  </QueryClientProvider>
);

const rootElement = document.getElementById('root');
render(root, rootElement);
