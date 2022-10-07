// Entry point for the build script in your package.json
import '@hotwired/turbo-rails';
import React from 'react';
import { render } from 'react-dom';
import {
  BrowserRouter as Router, Routes, Route, Navigate,
} from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import './i18n';
import App from './App';
import Signup from './components/users/authentication/Signup';
import SignIn from './components/users/authentication/SignIn';
import AuthProvider from './contexts/auth/AuthProvider';
import Profile from './components/users/user/Profile';
import Room from './components/rooms/room/Room';
import Rooms from './components/rooms/Rooms';
import HomePage from './components/home/HomePage';
import RoomJoin from './components/rooms/room/RoomJoin';
import ForgetPassword from './components/users/password_management/ForgetPassword';
import ManageUsers from './components/admin/manage_users/ManageUsers';
import ServerRecordings from './components/admin/server_recordings/ServerRecordings';
import ServerRooms from './components/admin/server_rooms/ServerRooms';
import SiteSettings from './components/admin/site_settings/SiteSettings';
import RoomConfig from './components/admin/room_configuration/RoomConfig';
import Roles from './components/admin/roles/Roles';
import ResetPassword from './components/users/password_management/ResetPassword';
import EditUser from './components/admin/manage_users/EditUser';
import EditRole from './components/admin/roles/EditRole';
import Home from './components/home/Home';
import ActivateAccount from './components/users/account_activation/ActivateAccount';
import ErrorBoundary from './components/shared_components/ErrorBoundary';
import DefaultErrorPage from './components/errors/DefaultErrorPage';
import NotFoundPage from './components/errors/NotFoundPage';
import VerifyAccount from './components/users/account_activation/VerifyAccount';

const queryClient = new QueryClient();

const root = (
  <React.Suspense fallback="Loading...">
    <ErrorBoundary fallback={DefaultErrorPage}>
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
                <Route path="/activate_account/:token" element={<ActivateAccount />} />
                <Route path="/verify_account" element={<VerifyAccount />} />
                <Route path="/profile" element={<Profile />} />
                <Route path="/admin" element={<Navigate to="/admin/users" replace />} />
                <Route path="/admin/users" element={<ManageUsers />} />
                <Route path="/admin/edit_user/:userId" element={<EditUser />} />
                <Route path="/admin/server-recordings" element={<ServerRecordings />} />
                <Route path="/admin/server-rooms" element={<ServerRooms />} />
                <Route path="/admin/room-configuration" element={<RoomConfig />} />
                <Route path="/admin/site-settings" element={<SiteSettings />} />
                <Route path="/admin/roles" element={<Roles />} />
                <Route path="/admin/roles/edit/:roleId" element={<EditRole />} />
                <Route path="/rooms" element={<Rooms />} />
                <Route path="/rooms/:friendlyId" element={<Room />} />
                <Route path="/rooms/:friendlyId/join" element={<RoomJoin />} />
                <Route path="/home" element={<Home />} />
                <Route path="/404" element={<NotFoundPage />} />
                <Route path="*" element={<Navigate to="404" />} />
              </Route>
            </Routes>
          </Router>
        </AuthProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  </React.Suspense>
);

const rootElement = document.getElementById('root');
render(root, rootElement);
