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

import { Dropdown } from 'react-bootstrap';
import React from 'react';
import PropTypes from 'prop-types';
import { ChevronDownIcon } from '@heroicons/react/20/solid';

export default function SimpleSelect({ defaultValue, dropUp, children }) {
  // Get the currently selected option and set the dropdown toggle to that value
  console.log(children)
  const defaultString = children?.filter((item) => item.props.value === defaultValue)[0];

  return (
    <Dropdown className="simple-select" drop={dropUp ? 'up' : undefined}>
      <Dropdown.Toggle>
        { defaultString?.props?.children }
        <ChevronDownIcon className="hi-s float-end" />
      </Dropdown.Toggle>
      <Dropdown.Menu>
        {children}
      </Dropdown.Menu>
    </Dropdown>
  );
}

SimpleSelect.defaultProps = {
  defaultValue: '',
  dropUp: false,
  children: undefined,
};

SimpleSelect.propTypes = {
  defaultValue: PropTypes.string,
  dropUp: PropTypes.bool,
  children: PropTypes.arrayOf(PropTypes.element),
};
