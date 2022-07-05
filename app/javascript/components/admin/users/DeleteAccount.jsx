import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import Modal from '../../shared/Modal';
// import DeleteUserForm from '../forms/DeleteUserForm';
import DeleteUserForm from '../DeleteUserForm';

export default function DeleteAccount({ userId }) {
  return (
    <div id="delete-account">
      <h3 className="mb-4"> Permanently Delete User </h3>
      <p className="text-muted pb-2">
        If you choose to delete this account, it will NOT be recoverable.
        <br />
        All information regarding this account, including settings, rooms, and recordings will be removed.
      </p>
      <Modal
        modalButton={<Button variant="danger">Yes, I would like to delete this account</Button>}
        title="Are you sure?"
        body={<DeleteUserForm userId={userId} />}
      />
    </div>
  );
}

DeleteAccount.propTypes = {
  userId: PropTypes.string.isRequired,
};
