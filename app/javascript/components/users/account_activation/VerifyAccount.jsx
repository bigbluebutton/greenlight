import React from 'react';
import {
  Button, Card,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useCreateActivationLink from '../../../hooks/mutations/account_activation/useCreateActivationLink';
import Spinner from '../../shared_components/utilities/Spinner';
import Logo from '../../shared_components/Logo';

export default function VerifyAccount() {
  const currentUser = useAuth();
  const createActivationLinkAPI = useCreateActivationLink(currentUser?.email);
  const { t } = useTranslation();

  return (
    <div className="vertical-buffer">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm text-center">
        <Card.Title className="pb-2 fs-1 text-danger">{ t('account_activation_page.title') }</Card.Title>
        <strong className="mb-3">{ t('account_activation_page.account_unverified') }</strong>
        <span className="mb-3">{ t('account_activation_page.message') }</span>
        <span className="mb-4">{ t('account_activation_page.resend_activation_link') }</span>
        <Button
          variant="brand"
          className="btn btn-lg"
          onClick={createActivationLinkAPI.mutate}
          disabled={createActivationLinkAPI.isLoading}
        >
          { t('account_activation_page.resend_btn_lbl') } {createActivationLinkAPI.isLoading && <Spinner />}
        </Button>
      </Card>
    </div>
  );
}
