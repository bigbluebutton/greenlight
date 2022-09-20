/* eslint-disable react/jsx-props-no-spreading */

import React, { useState, useRef } from 'react';
import {
  Button, Col, Row, Stack, Form as BootstrapForm,
  Container,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { Link } from 'react-router-dom';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import { signinFormFields, signinFormConfig } from '../../../../helpers/forms/SigninFormHelpers';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateSession from '../../../../hooks/mutations/sessions/useCreateSession';
import useEnv from '../../../../hooks/queries/env/useEnv';

export default function SigninForm() {
  const { t } = useTranslation();
  const methods = useForm(signinFormConfig);
  const [token, setToken] = useState('');
  const createSession = useCreateSession(token);
  const { isSubmitting } = methods.formState;
  const fields = signinFormFields;
  const { isLoading, data: env } = useEnv();
  const captchaRef = useRef(null);

  if (isLoading) return <Spinner />;

  const onError = () => {
    toast.error(t('toast.error.problem_completing_action'));
  };

  const onExpire = () => {
    toast.error(t('toast.error.problem_completing_action'));
  };

  return (
    <Form
      methods={methods}
      onSubmit={async (data) => {
        const response = await captchaRef.current?.execute({ async: true });
        await createSession.mutate(data, response);
      }}
    >
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <Row>
        <Col>
          <FormControl
            control={BootstrapForm.Check}
            field={fields.extend_session}
            label={fields.extend_session.label}
            type="checkbox"
            noLabel
          />
        </Col>
        <Col>
          <Link to="/forget_password" className="text-link float-end small"> { t('authentication.forgot_password') } </Link>
        </Col>
      </Row>
      { env.HCAPTCHA_KEY
        && (
        <Container className="d-flex justify-content-center mt-3">
          <HCaptcha
            sitekey={env.HCAPTCHA_KEY}
            size="invisible"
            onVerify={(response) => setToken(response)}
            onError={onError}
            onExpire={onExpire}
            ref={captchaRef}
          />
        </Container>
        )}
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 my-3 py-2" type="submit" disabled={isSubmitting}>
          { t('authentication.sign_in') }
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}
