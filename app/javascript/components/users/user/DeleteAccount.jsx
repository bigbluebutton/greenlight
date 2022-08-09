import React from 'react';
import { Button } from 'react-bootstrap';
import Modal from '../../shared_components/modals/Modal';
import DeleteUserForm from './forms/DeleteUserForm';

export default function DeleteAccount() {
  return (
    <div id="delete-account">
      <h3 className="mb-4"> Permanently Delete Your Account </h3>
      <p className="text-muted pb-2">
        If you choose to delete your account, it will NOT be recoverable.
        <br />
        All information regarding your account, including settings, rooms, and recordings will be removed.
      </p>
      <Modal
        modalButton={<Button variant="danger">Yes, I would like to delete my account</Button>}
        title="Are you sure?"
        body={<DeleteUserForm />}
      />
    </div>
  );
}
