import React from 'react';
import UpdateUserForm from '../forms/UpdateUserForm';
import DeleteUserForm from '../forms/DeleteUserForm';
import DeleteModal from '../shared/stylings/DeleteModal';

export default function Profile() {
  return (
    <>
      <UpdateUserForm />
      <h1>Permanently Delete My Account</h1>
      <DeleteModal
        title="Are you sure?"
        body="All information regarding your account, including settings, rooms,
              and recording will be removed. This process cannot be undone."
      >
        <DeleteUserForm />
      </DeleteModal>
    </>
  );
}
