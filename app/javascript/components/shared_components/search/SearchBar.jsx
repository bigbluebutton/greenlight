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

import React, { useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash.debounce';
import { useTranslation } from 'react-i18next';

export default function SearchBar({ searchInput, setSearchInput }) {
  const { t } = useTranslation();

  const onChangeHandler = (event) => {
    setSearchInput(event.target.value);
  };

  const debouncedOnChangeHandler = useMemo(
    () => debounce(onChangeHandler, 300),
    [],
  );

  useEffect(() => () => {
    debouncedOnChangeHandler.cancel();
  }, [searchInput]);

  return (
    <input
      className="search-bar rounded border form-control"
      placeholder={t('search')}
      type="search"
      onChange={debouncedOnChangeHandler}
    />
  );
}

SearchBar.propTypes = {
  searchInput: PropTypes.string,
  setSearchInput: PropTypes.func.isRequired,
};

SearchBar.defaultProps = {
  searchInput: '',
};
