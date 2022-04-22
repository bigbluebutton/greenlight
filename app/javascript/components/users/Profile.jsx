import React from 'react';
import { Button } from 'react-bootstrap';
import DeleteUserForm from '../forms/DeleteUserForm';
import Modal from '../shared/Modal';

export default function Profile() {
  return (
    <>
      <h1>Permanently Delete My Account</h1>
      <Modal
        modalButton={<Button variant="danger">Delete</Button>}
        title="Are you sure?"
        body="All information regarding your account, including settings, rooms,
        and recording will be removed. This process cannot be undone."
        footer={<DeleteUserForm />}
      />
    </>
  );
}
