import React from 'react';
import { useTranslation } from 'react-i18next';
import { Stack } from 'react-bootstrap';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';

export default function NoSearchResults({ text, searchInput }) {
  const { t } = useTranslation();

  return (
    <Stack direction="vertical" className="d-block mx-auto text-center">
      <div className="icon-circle rounded-circle d-block mx-auto mb-3 bg-white">
        <MagnifyingGlassIcon className="hi-l text-brand d-block mx-auto pt-4" />
      </div>
      <h2>{text}</h2>
      <p>{t('no_result_search_input', { searchInput })}</p>
    </Stack>
  );
}

NoSearchResults.propTypes = {
  searchInput: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
};
