import React, { useEffect } from 'react';
import { Button, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import useUpdateUser from '../../../../hooks/mutations/users/useUpdateUser';
import Spinner from '../../../shared_components/utilities/Spinner';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoles from '../../../../hooks/queries/admin/roles/useRoles';
import FormSelect from '../../../shared_components/forms/controls/FormSelect';
import Option from '../../../shared_components/utilities/Option';
import useLocales from '../../../../hooks/queries/locales/useLocales';
import useUpdateUserForm from '../../../../hooks/forms/users/user/useUpdateUserForm';
import PermissionChecker from '../../../../helpers/PermissionChecker';

export default function UpdateUserForm({ user }) {
  const currentUser = useAuth();
  const localesAPI = useLocales();
  const updateUserAPI = useUpdateUser(user?.id);
  const { t, i18n } = useTranslation();

  const { methods, fields, reset } = useUpdateUserForm({
    defaultValues: {
      name: user?.name,
      email: user?.email,
      language: i18n.resolvedLanguage, // Whatever language is currently rendering (needed to handle unsupported languages)
      role_id: user?.role?.id,
    },
  });

  useEffect(() => {
    methods.setValue('language', i18n.resolvedLanguage);
  }, [i18n.resolvedLanguage]);

  const canUpdateRole = PermissionChecker.hasManageUsers(currentUser);
  const rolesAPI = useRoles({ enabled: canUpdateRole });

  return (
    <Form methods={methods} onSubmit={updateUserAPI.mutate}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormSelect field={fields.language} variant="dropdown">
        {
          Object.keys(localesAPI.data || {}).map((code) => <Option key={code} value={code}>{localesAPI.data[code]}</Option>)
        }
      </FormSelect>
      {(canUpdateRole && rolesAPI.data) && (
        <FormSelect field={fields.role_id} variant="dropdown">
          {
            rolesAPI.data.map((role) => <Option key={role.id} value={role.id}>{role.name}</Option>)
          }
        </FormSelect>
      )}
      <Stack direction="horizontal" gap={2} className="float-end">
        <Button variant="neutral" onClick={reset}> { t('cancel') } </Button>
        <Button variant="brand" type="submit" disabled={updateUserAPI.isLoading}>
          { t('update') }
          {updateUserAPI.isLoading && <Spinner className="me-2" />}
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
