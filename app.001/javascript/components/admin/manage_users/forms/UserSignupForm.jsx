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

import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useAdminCreateUser from '../../../../hooks/mutations/admin/manage_users/useAdminCreateUser';
import useUserSignupForm from '../../../../hooks/forms/admin/manage_users/useUserSignupForm';

export default function UserSignupForm({ handleClose }) {
  const { t } = useTranslation();
  const { fields, methods } = useUserSignupForm();
  const createUserAPI = useAdminCreateUser({ onSettled: handleClose });

  return (
    <Form methods={methods} onSubmit={createUserAPI.mutate}>
      <FormControl field={fields.name} type="text" autoFocus />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          {t('close')}
        </Button>
        <Button variant="brand" type="submit" disabled={createUserAPI.isLoading}>
          { createUserAPI.isLoading && <Spinner className="me-2" /> }
          { t('admin.manage_users.create_account') }
        </Button>
      </Stack>
    </Form>
  );
}

UserSignupForm.propTypes = {
  handleClose: PropTypes.func,
};

UserSignupForm.defaultProps = {
  handleClose: () => { },
};
