import React from 'react';
import { Card } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

import Logo from '../../shared_components/Logo';
import ButtonLink from '../../shared_components/utilities/ButtonLink';

export default function PendingRegistration() {
  const { t } = useTranslation();

  return (
    <div className="vertical-buffer">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 card-shadow text-center">
        <Card.Title className="pb-2 fs-1 text-danger">{ t('user.pending.title') }</Card.Title>
        <span className="mb-3">{ t('user.pending.message') }</span>
        <ButtonLink to="/" variant="brand" className="btn btn-lg m-2">
          {t('return_home')}
        </ButtonLink>
      </Card>
    </div>
  );
}
