import React from 'react';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import Form from '../../../shared_components/forms/Form';
import useDeleteAvatar from '../../../../hooks/mutations/users/useDeleteAvatar';

export default function DeleteAvatarForm({ user }) {
  const methods = useForm();
  const deleteAvatar = useDeleteAvatar(user);

  return (
    <Form methods={methods} onSubmit={deleteAvatar.mutate}>
      <button className="btn btn-link float-end" type="submit">
        Delete Avatar
      </button>
    </Form>
  );
}

DeleteAvatarForm.propTypes = {
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
