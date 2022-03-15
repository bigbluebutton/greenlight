import React, { useState, useMemo } from 'react';
import Routes from '../routes/Index';
import CurrentUser from './user/CurrentUser';
import AuthProvider from './sessions/AuthContext'

export default function App() {
  return (
    <AuthProvider>
      <CurrentUser />
      {Routes}
    </AuthProvider>
  );
}
