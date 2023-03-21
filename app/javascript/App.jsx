// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import {
  createBrowserRouter, createRoutesFromElements, Route, RouterProvider,
} from 'react-router-dom';
import Layout from './Layout';
import RootBoundary from './RootBoundary';
import HomePage from './components/home/HomePage';
import UnauthenticatedOnly from './routes/UnauthenticatedOnly';
import Signup from './components/users/authentication/Signup';
import SignIn from './components/users/authentication/SignIn';
import ForgetPassword from './components/users/password_management/ForgetPassword';
import PendingRegistration from './components/users/registration/PendingRegistration';
import VerifyAccount from './components/users/account_activation/VerifyAccount';
import ResetPassword from './components/users/password_management/ResetPassword';
import ActivateAccount from './components/users/account_activation/ActivateAccount';
import AuthenticatedOnly from './routes/AuthenticatedOnly';
import Profile from './components/users/user/Profile';
import Rooms from './components/rooms/Rooms';
import Room from './components/rooms/room/Room';
import CantCreateRoom from './components/rooms/CantCreateRoom';
import AdminPanel from './components/admin/AdminPanel';
import ManageUsers from './components/admin/manage_users/ManageUsers';
import EditUser from './components/admin/manage_users/EditUser';
import ServerRecordings from './components/admin/server_recordings/ServerRecordings';
import ServerRooms from './components/admin/server_rooms/ServerRooms';
import RoomConfig from './components/admin/room_configuration/RoomConfig';
import SiteSettings from './components/admin/site_settings/SiteSettings';
import Roles from './components/admin/roles/Roles';
import EditRole from './components/admin/roles/EditRole';
import Tenants from './components/admin/tenants/Tenants';
import RoomJoin from './components/rooms/room/join/RoomJoin';
import useEnv from './hooks/queries/env/useEnv';

export default function App() {
  const envAPI = useEnv();

  if (envAPI.isLoading) {
    return null;
  }

  const router = createBrowserRouter(
    createRoutesFromElements(
      <Route
        path="/"
        element={<Layout />}
        errorElement={<RootBoundary />}
      >
        <Route index element={<HomePage />} />

        <Route element={<UnauthenticatedOnly />}>
          <Route path="/signup" element={<Signup />} />
          <Route path="/signin" element={<SignIn />} />
          <Route path="/forget_password" element={<ForgetPassword />} />
          <Route path="/pending" element={<PendingRegistration />} />
          <Route path="/verify" element={<VerifyAccount />} />
          <Route path="/reset_password/:token" element={<ResetPassword />} />
          <Route path="/activate_account/:token" element={<ActivateAccount />} />
        </Route>

        <Route element={<AuthenticatedOnly />}>
          <Route path="/profile" element={<Profile />} />
          <Route path="/rooms" element={<Rooms />} />
          <Route path="/rooms/:friendlyId" element={<Room />} />
          <Route path="/home" element={<CantCreateRoom />} />
          <Route path="/admin" element={<AdminPanel />} />
          <Route path="/admin/users" element={<ManageUsers />} />
          <Route path="/admin/users/edit/:userId" element={<EditUser />} />
          <Route path="/admin/server_recordings" element={<ServerRecordings />} />
          <Route path="/admin/server_rooms" element={<ServerRooms />} />
          <Route path="/admin/room_configuration" element={<RoomConfig />} />
          <Route path="/admin/site_settings" element={<SiteSettings />} />
          <Route path="/admin/roles" element={<Roles />} />
          <Route path="/admin/roles/edit/:roleId" element={<EditRole />} />
          <Route path="/admin/tenants" element={<Tenants />} />
        </Route>

        <Route path="/rooms/:friendlyId/join" element={<RoomJoin />} />
      </Route>,
    ),
    { basename: envAPI.data.RELATIVE_URL_ROOT },
  );

  return (
    <RouterProvider router={router} />
  );
}
