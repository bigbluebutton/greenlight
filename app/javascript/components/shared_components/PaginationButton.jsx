import React from 'react';
import Button from 'react-bootstrap/Button';
import { ArrowLeftIcon, ArrowRightIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';

export default function PaginationButton({ direction, page, totalPages }) {
  const { t } = useTranslation();

  if (direction === 'Previous') {
    if (page === 1) {
      return (
        <Button variant="brand-outline" disabled>
          <ArrowLeftIcon className="me-3 hi-s" />
          { t('previous') }
        </Button>
      );
    }

    return (
      <Button variant="brand-outline">
        <ArrowLeftIcon className="me-3 hi-s text-brand" />
        { t('previous') }
      </Button>
    );
  }

  if (direction === 'Next') {
    if (page === totalPages) {
      return (
        <Button variant="brand-outline" disabled>
          { t('next') }
          <ArrowRightIcon className="ms-3 hi-s" />
        </Button>
      );
    }

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
  page: PropTypes.number.isRequired,
  totalPages: PropTypes.number.isRequired,
};
