import React from 'react';
import { useForm } from 'react-hook-form';
import { Button, Form as BootStrapForm, Stack } from 'react-bootstrap';
import { yupResolver } from '@hookform/resolvers/yup';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { validationSchema, updateUserFormFields } from '../../../../helpers/forms/UpdateUserFormHelpers';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import useUpdateUser from '../../../../hooks/mutations/users/useUpdateUser';
import Spinner from '../../../shared_components/utilities/Spinner';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoles from '../../../../hooks/queries/admin/roles/useRoles';

export default function UpdateUserForm({ user }) {
  const { t } = useTranslation();

  // TODO: Make LOCALES a context that provides the available languages and their native names in the client app.
  const LOCALES = {
    en: 'English',
    ar: 'العربيّة',
    fr: 'Français',
    es: 'Española',
  };

  const methods = useForm({
    defaultValues: {
      name: user?.name,
      email: user?.email,
      language: user?.language,
      role_id: user?.role?.id,
    },
    resolver: yupResolver(validationSchema),
  });

  const { formState: { isSubmitting } } = methods;
  const updateUser = useUpdateUser(user?.id);
  const fields = updateUserFormFields;
  const currentUser = useAuth();

  const isAdmin = currentUser.permissions.ManageUsers === 'true';
  const { data: roles, isLoading } = useRoles('', isAdmin);

  if (isLoading) return <Spinner />;

  return (
    <Form methods={methods} onSubmit={updateUser.mutate}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.language} control={BootStrapForm.Select}>
        {
          Object.keys(LOCALES).map((code) => <option key={code} value={code}>{LOCALES[code]}</option>)
        }
      </FormControl>
      {isAdmin && (
        <FormControl field={fields.role_id} control={BootStrapForm.Select}>
          {
            roles.map((role) => <option key={role.id} value={role.id}>{role.name}</option>)
          }
        </FormControl>
      )}

      <Stack direction="horizontal" gap={2} className="float-end">
        <Button
          variant="brand-outline"
          onClick={() => methods.reset({
            name: user.name,
            email: user.email,
          })}
        >
          Cancel
        </Button>
        <Button variant="brand" type="submit" disabled={isSubmitting}>
          { t('update') }
          {
            isSubmitting && <Spinner />
          }
        </Button>
      </Stack>
    </Form>
  );
}

UpdateUserForm.propTypes = {
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
    language: PropTypes.string.isRequired,
  }).isRequired,
};
