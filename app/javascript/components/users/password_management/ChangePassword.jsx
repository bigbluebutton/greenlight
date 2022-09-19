import React from 'react';
import { Row } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import ChangePwdForm from './forms/ChangePwdForm';

export default function ChangePassword() {
  const { t } = useTranslation();

  return (
    <>
      <Row>
        <h3 className="mb-4"> { t('user.account.change_password')} </h3>
      </Row>
      <Row>
        <ChangePwdForm />
      </Row>
    </>
  );
}
