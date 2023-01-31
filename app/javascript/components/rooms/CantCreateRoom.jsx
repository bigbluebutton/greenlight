import React from 'react';
import { Card, Stack } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { useTranslation } from 'react-i18next';
import Logo from '../shared_components/Logo';

// This page is shown is the current_user does NOT have CreateRoom permission
export default function CantCreateRoom() {
  const { t } = useTranslation();

  return (
    <div className="mt-5">
      <div className="text-center mb-4">
        <Logo />
      </div>
      <Card className="col-md-8 mx-auto p-5 border-0 shadow-sm text-center">
        <div className="mt-4 px-xxl-5">
          <div className="text-start">
            <h6> { t('homepage.enter_meeting_url') } </h6>
            <Stack direction="horizontal">
              <input className="form-control" id="joinUrl" />
              <Button variant="brand" className="ms-2">{ t('join') }</Button>
            </Stack>
          </div>
        </div>
      </Card>
    </div>
  );
}
