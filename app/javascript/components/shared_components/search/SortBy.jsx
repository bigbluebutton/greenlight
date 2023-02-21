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
import PropTypes from 'prop-types';
import { useSearchParams } from 'react-router-dom';
import { ChevronDownIcon, ChevronUpIcon, ChevronUpDownIcon } from '@heroicons/react/24/outline';

function IconFactory(fieldName, column, direction) {
  if (column === fieldName) {
    if (direction === 'ASC') {
      return ChevronUpIcon;
    }
    if (direction === 'DESC') {
      return ChevronDownIcon;
    }
  }

  return ChevronUpDownIcon;
}

export default function SortBy({ className, fieldName }) {
  const [searchParams, setSearchParams] = useSearchParams();

  const column = searchParams.get('sort[column]');
  const direction = searchParams.get('sort[direction]');

  const handleClick = () => {
    if (column !== fieldName || (direction !== 'ASC' && direction !== 'DESC')) {
      searchParams.set('sort[column]', fieldName);
      searchParams.set('sort[direction]', 'ASC');
    } else if (direction === 'ASC') {
      searchParams.set('sort[direction]', 'DESC');
    } else {
      searchParams.delete('sort[column]');
      searchParams.delete('sort[direction]');
    }
    setSearchParams(searchParams);
  };

  const Icon = IconFactory(fieldName, column, direction);

  return (
    <Icon className={className} onClick={handleClick} />
  );
}

SortBy.defaultProps = {
  className: 'cursor-pointer hi-xs',
};

SortBy.propTypes = {
  className: PropTypes.string,
  fieldName: PropTypes.string.isRequired,
};
