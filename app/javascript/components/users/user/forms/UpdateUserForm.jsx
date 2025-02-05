// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React, { useEffect } from 'react';
import {
  Button, Stack,
} from 'react-bootstrap';
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
  const { t } = useTranslation();
  const currentUser = useAuth();

  // User with ManageUsers permission can update any user except themselves
  const canUpdateRole = PermissionChecker.hasManageUsers(currentUser) && currentUser.id !== user.id;

  const { data: roles } = useRoles({ enabled: canUpdateRole });
  const { data: locales } = useLocales();
  const updateUserAPI = useUpdateUser(user?.id);

  function currentLanguage() {
    const language = user?.language;
    const noDialect = language.substring(0, language.indexOf('-'));

    if (locales?.[language] !== undefined) {
      return language;
    } if (noDialect !== '' && locales?.[noDialect] !== undefined) {
      return noDialect;
    }
    return 'en';
  }

  const { methods, fields, reset } = useUpdateUserForm({
    defaultValues: {
      name: user?.name,
      email: user?.email,
      language: currentLanguage(),
      role_id: user?.role?.id,
    },
  });

  useEffect(() => {
    methods.setValue('language', currentLanguage());
  }, [currentLanguage()]);

  return (
    <Form methods={methods} onSubmit={updateUserAPI.mutate}>
      <FormControl field={fields.name} type="text" readOnly={user.external_account && !PermissionChecker.hasManageUsers(currentUser)} />
      <FormControl field={fields.email} type="email" readOnly />
      <FormSelect field={fields.language} variant="dropdown">
        {
          Object.keys(locales || {}).map((code) => <Option key={code} value={code}>{locales[code]}</Option>)
        }
      </FormSelect>
      {(canUpdateRole && roles) && (
        <FormSelect field={fields.role_id} variant="dropdown">
          {
            roles.map((role) => <Option key={role.id} value={role.id}>{role.name}</Option>)
          }
        </FormSelect>
      )}
      <Stack direction="horizontal" gap={2} className="float-end">
        <Button variant="neutral" onClick={reset}> { t('reset') } </Button>
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
    external_account: PropTypes.bool.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
    language: PropTypes.string.isRequired,
  }).isRequired,
};
