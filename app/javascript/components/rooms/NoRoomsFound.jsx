import React from 'react';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';

export default function NoRoomsFound({ searchInput }) {
  const { t } = useTranslation();

  return (
    <Stack direction="vertical" className="d-block mx-auto text-center">
      <div className="icon-circle rounded-circle d-block mx-auto mb-3 bg-white">
        <MagnifyingGlassIcon className="hi-l text-brand d-block mx-auto pt-4" />
      </div>
      <h2>{t('room.no_rooms_found')}</h2>
      <p>{t('no_result_search_input', { searchInput })}</p>
    </Stack>
  );
}

NoRoomsFound.propTypes = {
  searchInput: PropTypes.string.isRequired,
};
