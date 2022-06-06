import React, { useState, useRef } from 'react';
import {
  Button, Col, Row, Stack, Form as BootstrapForm,
  Container,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { Link } from 'react-router-dom';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import FormControl from './FormControl';
import Form from './Form';
import { signinFormFields, signinFormConfig } from '../../helpers/forms/SigninFormHelpers';
import Spinner from '../shared/stylings/Spinner';
import useCreateSession from '../../hooks/mutations/sessions/useCreateSession';
import useEnv from '../../hooks/queries/env/useEnv';

export default function SigninForm() {
  const methods = useForm(signinFormConfig);
  const [token, setToken] = useState('');
  const { onSubmit } = useCreateSession(token);
  const { isSubmitting } = methods.formState;
  const fields = signinFormFields;
  const { isLoading, data: env } = useEnv();
  const captchaRef = useRef(null);

  if (isLoading) return <Spinner />;

  const onError = (err) => {
    console.log(`hCaptcha Error: ${err}`);
  };

  const onExpire = () => {
    console.log('hCaptcha Token Expired');
  };

  return (
    <Form
      methods={methods}
      onSubmit={(data) => {
        captchaRef.current.execute({ async: true })
          .then(({ response }) => {
            onSubmit(data, response);
          });
      }}
    >
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <Row>
        <Col>
          <BootstrapForm.Group className="mb-2" controlId="formBasicCheckbox">
            <BootstrapForm.Check type="checkbox" label="Remember me" className="small" />
          </BootstrapForm.Group>
        </Col>
        <Col>
          <Link to="/" className="text-link float-end small"> Forgot password? </Link>
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
        <Button variant="primary" className="w-100 my-3 py-2" type="submit" disabled={isSubmitting}>
          Sign In
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}
