import React from 'react';
import {
  Card, Container,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Logo from '../shared_components/Logo';
import ButtonLink from '../shared_components/utilities/ButtonLink';

export default function DefaultErrorPage() {
  const { t } = useTranslation();

  return (
    <Container className="no-header-height">
      <div className="vertical-center">
        <div className="text-center pb-4">
          <Logo size="medium" />
        </div>
        <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm text-center">
          <Card.Title className="pb-2 fs-1 text-danger">{ t('global_error_page.title') }</Card.Title>
          <span className="mb-3">{ t('global_error_page.message') }</span>
          <ButtonLink to="/" variant="brand" className="btn btn-lg m-2">
            {t('return_home')}
          </ButtonLink>
        </Card>
      </div>
    </Container>
  );
}
