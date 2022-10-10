import React from 'react';
import {
  Button, Card, Col, Row,
} from 'react-bootstrap';
import { InformationCircleIcon } from '@heroicons/react/24/outline';
import { Navigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useCreateActivationLink from '../../../hooks/mutations/account_activation/useCreateActivationLink';
import Spinner from '../../shared_components/utilities/Spinner';

export default function VerifyAccount() {
  const currentUser = useAuth();
  const createActivationLinkAPI = useCreateActivationLink(currentUser?.email);
  const { t } = useTranslation();

  if (!currentUser.signed_in) {
    return <Navigate to="/signin" />;
  }

  if (currentUser.active) {
    return <Navigate to="/" />;
  }

  return (
    <Row className="vertical-center text-center">
      <Row className="mb-2">
        <h1>{t('account_activation_page.title')}</h1>
      </Row>
      <Row>
        <Col md={8} className="mx-auto">
          <Card className="p-5 border-0 shadow-sm">
            <Card.Title className="text-center pb-2"> <InformationCircleIcon className="hi-xl" /> </Card.Title>
            <pre className="text-muted">
              {t('account_activation_page.message')}
            </pre>
            <Button variant="brand" onClick={createActivationLinkAPI.mutate} disabled={createActivationLinkAPI.isLoading}>
              {t('account_activation_page.resend_btn_lbl')} {createActivationLinkAPI.isLoading && <Spinner />}
            </Button>
          </Card>
        </Col>
      </Row>
    </Row>
  );
}
