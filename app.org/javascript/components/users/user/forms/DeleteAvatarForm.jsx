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
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Button from 'react-bootstrap/Button';
import Form from '../../../shared_components/forms/Form';
import useDeleteAvatar from '../../../../hooks/mutations/users/useDeleteAvatar';
import Spinner from '../../../shared_components/utilities/Spinner';

export default function DeleteAvatarForm({ user }) {
  const { t } = useTranslation();
  const methods = useForm();
  const deleteAvatarAPI = useDeleteAvatar(user);

  return (
    <Form methods={methods} onSubmit={deleteAvatarAPI.mutate}>
      <Button type="submit" variant="delete" className="w-100" disabled={deleteAvatarAPI.isLoading}>
        {t('user.avatar.delete_avatar')}
        {deleteAvatarAPI.isLoading && <Spinner className="me-2" />}
      </Button>
    </Form>
  );
}

DeleteAvatarForm.propTypes = {
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
