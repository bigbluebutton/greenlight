import React from 'react';
import DeleteUserForm from '../forms/DeleteUserForm';
import Modal from '../shared/stylings/Modal';

export default function Profile() {
  return (
    <>
      <h1>Permanently Delete My Account</h1>
      <Modal
        title="Are you sure?"
        body="All information regarding your account, including settings, rooms,
              and recording will be removed. This process cannot be undone."
      >
        <DeleteUserForm />
      </Modal>
    </>
  );
}
