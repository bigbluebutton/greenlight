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
import useSignInForm from '../../../../hooks/forms/authentication/useSignInForm';
import HCaptcha from '../../../shared_components/utilities/HCaptcha';
import FormCheckBox from '../../../shared_components/forms/controls/FormCheckBox';

export default function SigninForm() {
  const { t } = useTranslation();
  const { methods, fields } = useSignInForm();
  const createSessionAPI = useCreateSession();
  const captchaRef = useRef(null);

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
          <FormCheckBox field={fields.extend_session} />
        </Col>
        <Col>
          <Link to="/forget_password" className="text-link float-end small"> {t('authentication.forgot_password')} </Link>
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
