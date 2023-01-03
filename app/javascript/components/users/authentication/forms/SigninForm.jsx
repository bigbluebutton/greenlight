/* eslint-disable react/jsx-props-no-spreading */

import React, {
  useRef, useMemo, useCallback,
} from 'react';
import {
  Button, Col, Row, Stack, Form as BootstrapForm,
  Container,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import FormControlGeneric from '../../../shared_components/forms/FormControlGeneric';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateSession from '../../../../hooks/mutations/sessions/useCreateSession';
import useEnv from '../../../../hooks/queries/env/useEnv';
import useSignInForm from '../../../../hooks/forms/authentication/useSignInForm';

export default function SigninForm() {
  const captchaRef = useRef(null);
  const { t } = useTranslation();
  const { methods, fields } = useSignInForm();
  const createSessionAPI = useCreateSession();
  const { data: env } = useEnv();

  const handleSubmit = useCallback(async (session) => {
    const results = await captchaRef.current?.execute({ async: true });
    const token = results?.response || '';

    return createSessionAPI.mutate({ session, token });
  }, [captchaRef.current, createSessionAPI.mutate]);

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

    handleVerified: () => {
      toast.success(t('toast.success.user.challenge_passed'));
    },
  }), []);

  return (
    <Form methods={methods} onSubmit={handleSubmit}>
      <FormControl field={fields.email} type="email" autoFocus />
      <FormControl field={fields.password} type="password" />
      <Row>
        <Col>
          <FormControlGeneric
            control={BootstrapForm.Check}
            field={fields.extend_session}
            label={fields.extend_session.label}
            type="checkbox"
          />
        </Col>
        <Col>
          <Link to="/forget_password" className="text-link float-end small"> {t('authentication.forgot_password')} </Link>
        </Col>
      </Row>
      {env?.HCAPTCHA_KEY
        && (
          <Container className="d-flex justify-content-center mt-3">
            <HCaptcha
              sitekey={env.HCAPTCHA_KEY}
              size="invisible"
              onVerify={HCaptchaHandlers.handleVerified}
              onError={HCaptchaHandlers.handleError}
              onExpire={HCaptchaHandlers.handleExpire}
              onChalExpired={HCaptchaHandlers.handleChalExpired}
              ref={captchaRef}
            />
          </Container>
        )}
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 my-3 py-2" type="submit" disabled={createSessionAPI.isLoading}>
          {createSessionAPI.isLoading && <Spinner className="me-2" />}
          {t('authentication.sign_in')}
        </Button>
      </Stack>
    </Form>
  );
}
