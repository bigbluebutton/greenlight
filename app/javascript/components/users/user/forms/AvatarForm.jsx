import React from 'react';
import { useForm } from 'react-hook-form';
import { Button } from 'react-bootstrap';
import { yupResolver } from '@hookform/resolvers/yup';
import PropTypes from 'prop-types';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
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
