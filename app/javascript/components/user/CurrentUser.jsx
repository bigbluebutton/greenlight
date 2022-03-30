import React from 'react';
import { Link } from 'react-router-dom';
import Stack from 'react-bootstrap/Stack';
import { useAuth } from '../sessions/AuthContext';

export default function CurrentUser() {
  const currentUser = useAuth();

  return (
    <Stack>
      <span> Name: { currentUser?.name }</span>
      <span> Email: { currentUser?.email }</span>
      <span> Provider: { currentUser?.provider }</span>
      <span> Signed In: { currentUser?.signed_in.toString() }</span>
      <Link to="/sign_in">Sign In</Link>
      <Link to="/signup">Sign Up</Link>
    </Stack>
  );
}
