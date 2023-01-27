// Entry point for the build script in your package.json
import '@hotwired/turbo-rails';
import * as React from 'react';
import { render } from 'react-dom';
import {
  Route, RouterProvider, createBrowserRouter, createRoutesFromElements,
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
import RoomJoin from './components/rooms/room/join/RoomJoin';
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
import VerifyAccount from './components/users/account_activation/VerifyAccount';
import AdminPanel from './components/admin/AdminPanel';
import UnauthenticatedOnly from './routes/UnauthenticatedOnly';
import AuthenticatedOnly from './routes/AuthenticatedOnly';
import PendingRegistration from './components/users/registration/PendingRegistration';
import RootBoundary from './RootBoundary';

const queryClientConfig = {
  defaultOptions: {
    queries: {
      useErrorBoundary: true,
    },
  },
};

const queryClient = new QueryClient(queryClientConfig);

const router = createBrowserRouter(
  createRoutesFromElements(
    <Route
      path="/"
      element={<App />}
      errorElement={<RootBoundary />}
    >
      <Route index element={<HomePage />} />

      <Route element={<UnauthenticatedOnly />}>
        <Route path="/signup" element={<Signup />} />
        <Route path="/signin" element={<SignIn />} />
        <Route path="/forget_password" element={<ForgetPassword />} />
        <Route path="/pending" element={<PendingRegistration />} />
      </Route>

      <Route element={<AuthenticatedOnly />}>
        <Route path="/rooms" element={<Rooms />} />
        <Route path="/rooms/:friendlyId" element={<Room />} />
        <Route path="/home" element={<Home />} />

        <Route path="/admin" element={<AdminPanel />} />
        <Route path="/admin/users" element={<ManageUsers />} />
        <Route path="/admin/users/edit/:userId" element={<EditUser />} />
        <Route path="/admin/server_recordings" element={<ServerRecordings />} />
        <Route path="/admin/server_rooms" element={<ServerRooms />} />
        <Route path="/admin/room_configuration" element={<RoomConfig />} />
        <Route path="/admin/site_settings" element={<SiteSettings />} />
        <Route path="/admin/roles" element={<Roles />} />
        <Route path="/admin/roles/edit/:roleId" element={<EditRole />} />
      </Route>

      <Route path="/reset_password/:token" element={<ResetPassword />} />
      <Route path="/activate_account/:token" element={<ActivateAccount />} />
      <Route path="/verify_account" element={<VerifyAccount />} />
      <Route path="/profile" element={<Profile />} />
      <Route path="/rooms/:friendlyId/join" element={<RoomJoin />} />

    </Route>,
  ),
);

const rootElement = document.getElementById('root');
render(
  // eslint-disable-next-line react/jsx-no-useless-fragment
  <React.Suspense fallback={<></>}>
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <RouterProvider router={router} />
      </AuthProvider>
    </QueryClientProvider>
  </React.Suspense>,
  rootElement,
);
