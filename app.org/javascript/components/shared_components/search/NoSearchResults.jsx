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
