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
import { Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Modal from '../../shared_components/modals/Modal';
import DeleteUserForm from './forms/DeleteUserForm';

export default function DeleteAccount() {
  const { t } = useTranslation();

  return (
    <div id="delete-account">
      <h3 className="mb-4"> { t('user.account.permanently_delete_account') } </h3>
      <p className="text-muted pb-2">
        { t('user.account.delete_account_description') }
      </p>
      <Modal
        modalButton={<Button variant="delete">{ t('user.account.delete_account_confirmation') }</Button>}
        body={<DeleteUserForm />}
      />
    </div>
  );
}
