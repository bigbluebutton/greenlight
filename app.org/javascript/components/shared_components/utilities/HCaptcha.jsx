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

import React, { useMemo } from 'react';
import { Container } from 'react-bootstrap';
import OriginHCaptcha from '@hcaptcha/react-hcaptcha';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import useEnv from '../../../hooks/queries/env/useEnv';

function HCaptcha(_props, ref) {
  const { t, i18n } = useTranslation();
  const envAPI = useEnv();

  const HCaptchaHandlers = useMemo(() => ({
    handleError: (err) => {
      console.error(err);
      toast.error(t('toast.error.problem_completing_action'));
    },

    handleExpire: () => {
      console.error('Token expired.');
      toast.error(t('toast.error.problem_completing_action'));
    },

    handleChalExpired: () => {
      console.error('Challenge expired, Timeout.');
      toast.error(t('toast.error.problem_completing_action'));
    },
  }), [i18n.resolvedLanguage]);

  if (!envAPI.data?.HCAPTCHA_KEY) {
    return null;
  }

  return (
    <Container className="d-flex justify-content-center mt-3">
      <OriginHCaptcha
        ref={ref}
        size="invisible"
        sitekey={envAPI.data.HCAPTCHA_KEY}
        onError={HCaptchaHandlers.handleError}
        onExpire={HCaptchaHandlers.handleExpire}
        onChalExpired={HCaptchaHandlers.handleChalExpired}
      />
    </Container>
  );
}

export default React.forwardRef(HCaptcha);
