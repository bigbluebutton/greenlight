import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useSearchParams } from 'react-router-dom';
import { ArrowSmDownIcon, ArrowSmUpIcon, SwitchVerticalIcon } from '@heroicons/react/outline';

function IconFactory(clicks) {
  switch (clicks) {
    case 1: return ArrowSmUpIcon;
    case 2: return ArrowSmDownIcon;
    default: return SwitchVerticalIcon;
  }
}

function useSortByParam(clicks, fieldName) {
  const [searchParams, setSearchParams] = useSearchParams();
  useEffect(() => {
    let sortDirection = '';
    if (clicks) {
      if (clicks === 1) {
        sortDirection = 'ASC';
      } else if (clicks === 2) {
        sortDirection = 'DESC';
      }
      searchParams.set('sort[column]', fieldName);
      searchParams.set('sort[direction]', sortDirection);
    } else {
      searchParams.delete('sort[column]');
      searchParams.delete('sort[direction]');
    }
    setSearchParams(searchParams);
  }, [clicks]);
}

export default function SortBy({ className, fieldName }) {
  const [clicks, setClicks] = useState(0);
  const handleClick = () => { setClicks((oldVal) => (oldVal + 1) % 3); };
  useSortByParam(clicks, fieldName);
  const Icon = IconFactory(clicks);

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
