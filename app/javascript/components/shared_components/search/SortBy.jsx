import React from 'react';
import PropTypes from 'prop-types';
import { useSearchParams } from 'react-router-dom';
import { ArrowSmDownIcon, ArrowSmUpIcon, SwitchVerticalIcon } from '@heroicons/react/outline';

function IconFactory(fieldName, column, direction) {
  if (column === fieldName) {
    if (direction === 'ASC') {
      return ArrowSmUpIcon;
    }
    if (direction === 'DESC') {
      return ArrowSmDownIcon;
    }
  }

  return SwitchVerticalIcon;
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
  className: 'cursor-pointer hi-s',
};

SortBy.propTypes = {
  className: PropTypes.string,
  fieldName: PropTypes.string.isRequired,
};
