import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import Modal from '../../shared/Modal';
import DeleteUserForm from '../DeleteUserForm';

export default function DeleteAccount({ user }) {
  return (
    <div id="delete-account">
      <h3 className="mb-4"> Permanently Delete {user.name}&quot;s account? </h3>
      <p className="text-muted pb-2">
        If you choose to delete this account, it will NOT be recoverable.
        <br />
        All information regarding this account, including settings, rooms, and recordings will be removed.
      </p>
      <Modal
        modalButton={<Button variant="danger">Yes, I would like to delete {user.name}</Button>}
        title="Are you sure?"
        body={<DeleteUserForm user={user} />}
      />
    </div>
  );
}

DeleteAccount.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
};
