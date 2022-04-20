import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button,
} from 'react-bootstrap';
import Form from './Form';
import useDeleteUser from '../../hooks/mutations/users/useDeleteUser';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Spinner from '../shared/stylings/Spinner';

export default function DeleteUserForm() {
  const currentUser = useAuth();
  const methods = useForm();
  const { isSubmitting } = methods.formState;
  const { onSubmit } = useDeleteUser(currentUser?.id);

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <Button variant="danger" type="submit" disabled={isSubmitting}>
        Delete
        { isSubmitting && <Spinner /> }
      </Button>
    </Form>
  );
}
