import React from 'react';
import { XCircleIcon } from '@heroicons/react/24/outline';
import {
  Card, Col, Row,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function NotFoundPage() {
  const { t } = useTranslation();

  return (
    <Row className="vertical-center text-center">
      <Row className="mb-2">
        <h1>{t('not_found_error_page.title')}</h1>
      </Row>
      <Row>
        <Col md={8} className="mx-auto">
          <Card className="p-5 border-0 shadow-sm">
            <XCircleIcon className="hi-xxl mx-auto" />
            <pre className="text-muted">
              {t('not_found_error_page.message')}
            </pre>
          </Card>
        </Col>
      </Row>
    </Row>
  );
}
