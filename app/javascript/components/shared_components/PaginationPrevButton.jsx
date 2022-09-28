import React from 'react';
import Button from 'react-bootstrap/Button';
import { ArrowLeftIcon, ArrowRightIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';

export default function PaginationButton({ direction }) {
  const { t } = useTranslation();

  if (direction === 'Previous') {
    return (
      <Button variant="brand-outline">
        <ArrowLeftIcon className="me-3 hi-s text-brand" />
        { t('previous') }
      </Button>
    );
  }

  if (direction === 'Next') {
    return (
      <Button variant="brand-outline">
        { t('next') }
        <ArrowRightIcon className="ms-3 hi-s text-brand" />
      </Button>
    );
  }
}

PaginationButton.propTypes = {
  direction: PropTypes.string.isRequired,
};
