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
