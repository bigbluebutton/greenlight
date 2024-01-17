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

import React, { useState } from 'react';
import {
  Button, Card, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Spinner from '../../shared_components/utilities/Spinner';
import Logo from '../../shared_components/Logo';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useUpdateUser from '../../../hooks/mutations/users/useUpdateUser';

export default function ConfirmTerms() {
  const { t } = useTranslation();

  const currentUser = useAuth();
  const updateUserAPI = useUpdateUser(currentUser?.id);
  const [isCheckedTerms, setIsCheckedTerms] = useState(currentUser?.confirm_terms || false);
  const [isCheckedEmails, setIsCheckedEmails] = useState(currentUser?.email_notifs || false);

  // Update the user's confirm_terms value when the button is clicked
  const handleConfirmTerms = () => {
    updateUserAPI.mutate({
      confirm_terms: isCheckedTerms,
      email_notifs: isCheckedEmails,
    });
  };

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 card-shadow">
        <Stack direction="vertical" className="py-3">
          <h3><strong>{ t('confirm_terms_page.title') }</strong></h3>
          <h5 className="mb-3">{ t('confirm_terms_page.account_unconfirmed') }</h5>
        </Stack>
        <span className="mb-3">{ t('confirm_terms_page.message') }</span>

        <Stack direction="horizontal">
          <Stack>
            {t('forms.user.signup.fields.confirm_terms.label')}
          </Stack>
          <div className="form-switch">
            <input
              className="form-check-input fs-5"
              type="checkbox"
              checked={isCheckedTerms}
              onChange={() => setIsCheckedTerms(!isCheckedTerms)}
            />
          </div>
        </Stack>

        <Stack direction="horizontal">
          <Stack>
            {t('forms.user.signup.fields.email_notifs.label')}
          </Stack>
          <div className="form-switch">
            <input
              className="form-check-input fs-5"
              type="checkbox"
              checked={isCheckedEmails}
              onChange={() => setIsCheckedEmails(!isCheckedEmails)}
            />
          </div>
        </Stack>

        <Button
          variant="brand"
          type="submit"
          disabled={!isCheckedTerms || updateUserAPI.isLoading}
          onClick={handleConfirmTerms}
          className="mt-2"
        >
          { t('confirm_terms_page.confirm_btn_lbl') }
          {updateUserAPI.isLoading && <Spinner className="me-2" />}
        </Button>
      </Card>
    </div>
  );
}
