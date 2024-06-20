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

/* eslint-disable react/jsx-props-no-spreading */

import React, { useRef, useCallback } from 'react';
import {
  Button, Col, Row, Stack,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateSession from '../../../../hooks/mutations/sessions/useCreateSession';
import useSignInForm from '../../../../hooks/forms/users/authentication/useSignInForm';
import HCaptcha from '../../../shared_components/utilities/HCaptcha';
import FormCheckBox from '../../../shared_components/forms/controls/FormCheckBox';
import useEnv from '../../../../hooks/queries/env/useEnv';

export default function SigninForm() {
  const { t } = useTranslation();
  const { methods, fields } = useSignInForm();
  const createSessionAPI = useCreateSession();
  const captchaRef = useRef(null);
  const { data: env } = useEnv();

  const handleSubmit = useCallback(async (session) => {
    const results = await captchaRef.current?.execute({ async: true });
    const token = results?.response || '';

    return createSessionAPI.mutate({ session, token });
  }, [captchaRef.current, createSessionAPI.mutate]);

  return (
    <Form methods={methods} onSubmit={handleSubmit}>
      <FormControl field={fields.email} type="email" autoFocus />
      <FormControl field={fields.password} type="password" />
      <Row>
        <Col>
          <FormCheckBox id={fields.extend_session.hookForm.id} field={fields.extend_session} />
        </Col>
        <Col>
          {
            env?.SMTP_ENABLED && (
              <Link to="/forget_password" className="text-link float-end small"> {t('authentication.forgot_password')} </Link>
            )
          }
        </Col>
      </Row>
      <HCaptcha ref={captchaRef} />
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 my-3 py-2" type="submit" disabled={createSessionAPI.isLoading}>
          {createSessionAPI.isLoading && <Spinner className="me-2" />}
          {t('authentication.sign_in')}
        </Button>
      </Stack>
    </Form>
  );
}
