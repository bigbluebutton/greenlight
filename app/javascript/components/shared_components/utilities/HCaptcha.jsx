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

    handleVerified: () => {
      toast.success(t('toast.success.success'));
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
        onVerify={HCaptchaHandlers.handleVerified}
        onError={HCaptchaHandlers.handleError}
        onExpire={HCaptchaHandlers.handleExpire}
        onChalExpired={HCaptchaHandlers.handleChalExpired}
      />
    </Container>
  );
}

export default React.forwardRef(HCaptcha);
