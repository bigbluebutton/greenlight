import React from 'react';
import { useForm } from 'react-hook-form';
import { Button } from 'react-bootstrap';
import { yupResolver } from '@hookform/resolvers/yup';
import PropTypes from 'prop-types';
import FormControl from '../../../forms/FormControl';
import Form from '../../../forms/Form';
import useCreateAvatar from '../../../../hooks/mutations/users/useCreateAvatar';
import { validationSchema, avatarFormFields } from '../../../../helpers/forms/AvatarFormHelpers';

export default function AvatarForm({ user }) {
  const methods = useForm({
    resolver: yupResolver(validationSchema),
  });
  const { isSubmitting } = methods.formState;
  const { onSubmit } = useCreateAvatar(user);
  const fields = avatarFormFields;

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.avatar} type="file" accept="image/*" />
      <Button variant="brand" className="w-100 my-3 py-2" type="submit" disabled={isSubmitting}>
        Change Avatar
      </Button>
    </Form>
  );
}

AvatarForm.propTypes = {
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
