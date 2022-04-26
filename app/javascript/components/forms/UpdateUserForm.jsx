import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Form as BootStrapForm, Stack,
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
      email: currentUser?.email,
    },
    resolver: yupResolver(validationSchema),
  });
  const { onSubmit } = useUpdateUser(currentUser?.id);
  const fields = updateUserFormFields;

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />

      <BootStrapForm.Group className="mb-3" controlId={fields.language.controlId}>
        <BootStrapForm.Label className="small mb-0">
          {fields.language.label}
        </BootStrapForm.Label>
        <BootStrapForm.Select field={fields.language} type="select" />
      </BootStrapForm.Group>

      <BootStrapForm.Group className="mb-3" controlId={fields.userRole.controlId}>
        <BootStrapForm.Label className="small mb-0">
          {fields.userRole.label}
        </BootStrapForm.Label>
        <BootStrapForm.Select field={fields.userRole} type="select" />
      </BootStrapForm.Group>

      <Stack direction="horizontal" gap={2} className="float-end">
        <Button
          variant="primary-reverse"
          onClick={() => methods.reset({
            name: currentUser.name,
            email: currentUser.email,
          })}
        >
          Cancel
        </Button>
        <Button variant="primary" type="submit">
          Update
        </Button>
      </Stack>
    </Form>
  );
}
