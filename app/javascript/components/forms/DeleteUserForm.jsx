import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button,
} from 'react-bootstrap';
import Form from './Form';
import useDeleteUser from '../../hooks/mutations/users/useDeleteUser';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function DeleteUserForm() {
  const currentUser = useAuth();
  const methods = useForm();
  const { onSubmit } = useDeleteUser(currentUser?.id);

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <Button variant="danger" type="submit">
        Delete
      </Button>
    </Form>
  );
}
