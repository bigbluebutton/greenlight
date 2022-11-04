import React from 'react';
import {
  Card,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Logo from '../shared_components/Logo';
import ButtonLink from '../shared_components/utilities/ButtonLink';

export default function NotFoundPage() {
  const { t } = useTranslation();

  return (
    <div className="vertical-buffer">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm text-center">
        <Card.Title className="pb-2 fs-1 text-danger">{ t('not_found_error_page.title') }</Card.Title>
        <span className="mb-3">{ t('not_found_error_page.message') }</span>
        <ButtonLink to="/" variant="brand" className="btn btn-lg m-2">
          {t('return_home')}
        </ButtonLink>
      </Card>
    </div>
  );
}
