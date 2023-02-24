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

import React, { useCallback, useContext } from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'react-bootstrap';
import SelectContext from '../contexts/SelectContext';
import { ACTIONS } from '../constants/SelectConstants';

export default function Option({ children: title, value }) {
  const { selected, dispatch } = useContext(SelectContext);
  const handleClick = useCallback(() => { dispatch({ type: ACTIONS.SELECT, msg: { value } }); }, [dispatch]);
  const isActive = selected.value === value;

  return (
    <Dropdown.Item onClick={handleClick} active={isActive}> {title} </Dropdown.Item>
  );
}

Option.propTypes = {
  children: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.bool]).isRequired,
};
