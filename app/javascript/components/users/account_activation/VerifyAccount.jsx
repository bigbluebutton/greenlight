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
import {
  Button, Card, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router-dom';
import useCreateActivationLink from '../../../hooks/mutations/account_activation/useCreateActivationLink';
import Spinner from '../../shared_components/utilities/Spinner';
import Logo from '../../shared_components/Logo';

export default function VerifyAccount() {
  const [searchParams] = useSearchParams();
  const userId = searchParams.get('id');

  const createActivationLinkAPI = useCreateActivationLink(userId);
  const { t } = useTranslation();

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 card-shadow">
        <Stack direction="vertical" className="py-3">
          <h3><strong>{ t('account_activation_page.title') }</strong></h3>
          <h5 className="mb-3">{ t('account_activation_page.account_unverified') }</h5>
        </Stack>
        <span className="mb-3">{ t('account_activation_page.message') }</span>
        <span className="mb-4">{ t('account_activation_page.resend_activation_link') }</span>
        <Button
          variant="brand"
          className="btn btn-lg"
          onClick={createActivationLinkAPI.mutate}
          disabled={createActivationLinkAPI.isLoading}
        >
          { t('account_activation_page.resend_btn_lbl') } {createActivationLinkAPI.isLoading && <Spinner className="me-2" />}
        </Button>
      </Card>
    </div>
  );
}
