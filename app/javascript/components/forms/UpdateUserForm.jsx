import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button,
} from 'react-bootstrap';
import { yupResolver } from '@hookform/resolvers/yup';
import { validationSchema, updateUserFormFields } from '../../helpers/forms/UpdateUserFormHelpers';
import Form from './Form';
import FormControl from './FormControl';
import useUpdateUser from '../../hooks/mutations/users/useUpdateUser';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function UpdateUserForm() {
  const currentUser = useAuth();
  const methods = useForm({
    defaultValues: {
      name: currentUser?.name,
    },
    resolver: yupResolver(validationSchema),
  });
  const { onSubmit } = useUpdateUser(currentUser?.id);
  const fields = updateUserFormFields;

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.name} type="text" />
      <Button variant="primary" type="submit">
        Update
      </Button>
    </Form>
  );
}
