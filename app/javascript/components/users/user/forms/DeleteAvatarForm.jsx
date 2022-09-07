import React from 'react';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import Button from 'react-bootstrap/Button';
import Form from '../../../shared_components/forms/Form';
import useDeleteAvatar from '../../../../hooks/mutations/users/useDeleteAvatar';

export default function DeleteAvatarForm({ user }) {
  const methods = useForm();
  const deleteAvatar = useDeleteAvatar(user);

  return (
    <Form methods={methods} onSubmit={deleteAvatar.mutate}>
      <Button variant="brand-backward" type="submit" className="w-100">
        Delete
      </Button>
    </Form>
  );
}

DeleteAvatarForm.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};
