// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
