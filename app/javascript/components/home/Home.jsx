import React from 'react';
import { Card, Stack } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import Logo from '../shared_components/Logo';

// This page is shown is the current_user does NOT have CreateRoom permission
export default function Home() {
  return (
    <div className="mt-5">
      <div className="text-center mb-4">
        <Logo size="large" />
      </div>
      <Card className="col-md-8 mx-auto p-5 border-0 shadow-sm text-center">
        <h1 className="mt-4"> Welcome to BigBlueButton. </h1>
        <div className="mt-4 px-xxl-5">
          <div className="text-start">
            <h6> Please enter the URL of your meeting. </h6>
            <Stack direction="horizontal">
              <input className="form-control" id="joinUrl" />
              <Button variant="brand" className="ms-2">Join</Button>
            </Stack>
          </div>
        </div>
      </Card>
    </div>
  );
}
