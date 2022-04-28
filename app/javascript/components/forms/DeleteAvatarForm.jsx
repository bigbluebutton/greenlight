import React from 'react';
import { useForm } from 'react-hook-form';
import Form from './Form';
import useDeleteAvatar from '../../hooks/mutations/users/useDeleteAvatar';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function DeleteUserForm() {
  const currentUser = useAuth();
  const methods = useForm();
  const { onSubmit } = useDeleteAvatar(currentUser);

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <button className="btn btn-link float-end" type="submit">
        Delete Avatar
      </button>
    </Form>
  );
}
