import React from 'react';
import Card from 'react-bootstrap/Card';
import { CheckCircleIcon } from '@heroicons/react/24/outline';
import { CloseButton, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';

export default function CustomToast({ variant, localeKey, dismiss }) {
  const { t } = useTranslation();
  const title = variant.charAt(0).toUpperCase() + variant.slice(1);

  return (
    <Card onClick={dismiss} className={`p-4 border-0 shadow-sm toast-card ${variant}-toast`}>
      <Stack direction="horizontal">
        <CheckCircleIcon className="hi-l" />
        <Stack direction="vertical" className="ps-3">
          <Stack direction="horizontal">
            <h5 className="mb-0 fw-bold"> {title} </h5>
            <CloseButton onClick={dismiss} className="d-block ms-auto mb-1" />
          </Stack>
          <p className="mb-0"> { t(localeKey) } </p>
        </Stack>
      </Stack>
    </Card>
  );
}

CustomToast.propTypes = {
  variant: PropTypes.string.isRequired,
  localeKey: PropTypes.string.isRequired,
  dismiss: PropTypes.func.isRequired,
}
