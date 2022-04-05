import React from 'react';
import { Link } from 'react-router-dom';
import Stack from 'react-bootstrap/Stack';
import Button from 'react-bootstrap/Button';
import { useAuth } from '../sessions/AuthContext';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';

export default function CurrentUser() {
  const currentUser = useAuth();

  // TODO - samuel: Should those two lines be in useDeleteSession somehow?
  const { mutate } = useDeleteSession();
  const signOut = () => mutate();

  return (
    <Stack>
      <span>
        {' '}
        Name:
        { currentUser?.name }
      </span>
      <span>
        {' '}
        Email:
        { currentUser?.email }
      </span>
      <span>
        {' '}
        Provider:
        { currentUser?.provider }
      </span>
      <span>
        {' '}
        Signed In:
        { currentUser?.signed_in.toString() }
      </span>

      { currentUser?.signed_in
        ? <Link to="/" onClick={signOut}>Sign Out</Link>
        : (
          <>
            <Link to="/signin">Sign In</Link>
            <Link to="/signup">Sign Up</Link>
          </>
        )}
    </Stack>
  );
}
