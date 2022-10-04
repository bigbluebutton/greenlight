import React from 'react';
import { ExclamationCircleIcon } from '@heroicons/react/24/outline';
import {
  Card, Col, Container, Row,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function DefaultErrorPage() {
  const { t } = useTranslation();

  return (
    <Container className="no-header-height">
      <Row className="vertical-center text-center">
        <Row className="mb-2">
          <h1>{t('global_error_page.title')}</h1>
        </Row>
        <Row>
          <Col md={8} className="mx-auto">
            <Card className="p-5 border-0 shadow-sm">
              <ExclamationCircleIcon className="hi-xxl mx-auto" />
              <pre className="text-muted">
                {t('global_error_page.message')}
              </pre>
            </Card>
          </Col>
        </Row>
      </Row>
    </Container>
  );
}
