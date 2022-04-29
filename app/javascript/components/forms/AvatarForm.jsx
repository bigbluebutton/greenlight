import React from 'react';
import { useForm } from 'react-hook-form';
import { Button } from 'react-bootstrap';
import { yupResolver } from '@hookform/resolvers/yup';
import FormControl from './FormControl';
import Form from './Form';
import useCreateAvatar from '../../hooks/mutations/users/useCreateAvatar';
import { useAuth } from '../../contexts/auth/AuthProvider';
import { validationSchema, avatarFormFields } from '../../helpers/forms/AvatarFormHelpers';

export default function AvatarForm() {
  const methods = useForm({
    resolver: yupResolver(validationSchema),
  });
  const { isSubmitting } = methods.formState;
  const currentUser = useAuth();
  const { onSubmit } = useCreateAvatar(currentUser);
  const fields = avatarFormFields;

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.avatar} type="file" accept="image/*" />
      <Button variant="primary" className="w-100 my-3 py-2" type="submit" disabled={isSubmitting}>
        Change Avatar
      </Button>
    </Form>
  );
}
