import React from 'react';
import { Link } from 'react-router-dom';
import Stack from 'react-bootstrap/Stack';

export default function Home() {
  return (
    <Stack gap={3}>
      <h1> Welcome to Greenlight V3 </h1>
      <Link to="/sign_in">Sign In</Link>
    </Stack>
  );
}
