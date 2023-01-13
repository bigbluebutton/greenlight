import React, { useRef, useMemo, useCallback } from 'react';
import { Button, Container, Stack } from 'react-bootstrap';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateUser from '../../../../hooks/mutations/users/useCreateUser';
import useEnv from '../../../../hooks/queries/env/useEnv';
import useSignUpForm from '../../../../hooks/forms/authentication/useSignUpForm';

export default function SignupForm() {
  const captchaRef = useRef(null);
  const { t } = useTranslation();
  const { fields, methods } = useSignUpForm();
  const createUserAPI = useCreateUser();
  const { data: env } = useEnv();

  const handleSubmit = useCallback(async (user) => {
    const results = await captchaRef.current?.execute({ async: true });
    const token = results?.response || '';

    return createUserAPI.mutate({ user, token });
  }, [captchaRef.current, createUserAPI.mutate]);

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
      <FormControl field={fields.name} type="text" autoFocus />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      { env?.HCAPTCHA_KEY
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
        <Button variant="brand" className="w-100 my-3 mt-1" type="submit" disabled={createUserAPI.isLoading}>
          { createUserAPI.isLoading && <Spinner className="me-2" /> }
          { t('authentication.create_account') }
        </Button>
      </Stack>
    </Form>
  );
}
