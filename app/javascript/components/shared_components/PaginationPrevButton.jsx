import React from 'react';
import Button from 'react-bootstrap/Button';
import { ArrowLeftIcon } from '@heroicons/react/outline';
import { ArrowRightIcon } from '@heroicons/react/solid';
import PropTypes from 'prop-types';

export default function PaginationButton({ direction }) {
  if (direction === 'Previous') {
    return (
      <Button variant="brand-backward">
        <ArrowLeftIcon className="me-3 hi-s text-brand" />
        {direction}
      </Button>
    );
  }

  if (direction === 'Next') {
    return (
      <Button variant="brand-backward">
        {direction}
        <ArrowRightIcon className="ms-3 hi-s text-brand" />
      </Button>
    );
  }
}

PaginationButton.propTypes = {
  direction: PropTypes.string.isRequired,
};
