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

import { Dropdown, Stack } from 'react-bootstrap';
import React from 'react';
import PropTypes from 'prop-types';
import { ChevronDownIcon } from '@heroicons/react/20/solid';

export default function SettingSelect({
  defaultValue, title, description, children,
}) {
  // Get the currently selected option and set the dropdown toggle to that value
  const defaultString = children?.filter((item) => item.props.value === defaultValue)[0];

  // Below md the select goes under its text.
  return (
    <div className="d-flex flex-column flex-md-row align-items-md-center gap-2 gap-md-0 mb-3">
      <Stack>
        <strong> { title } </strong>
        <div className="text-muted">{ description }</div>
      </Stack>
      <div className="setting-select-wrapper ms-md-5 flex-shrink-0">
        <Dropdown className="setting-select">
          <Dropdown.Toggle className="d-flex justify-content-between align-items-center gap-2">
            { defaultString?.props?.children }
            <ChevronDownIcon className="hi-s" aria-hidden="true" />
          </Dropdown.Toggle>
          <Dropdown.Menu>
            {children}
          </Dropdown.Menu>
        </Dropdown>
      </div>
    </div>
  );
}

SettingSelect.defaultProps = {
  defaultValue: '',
  children: undefined,
};

SettingSelect.propTypes = {
  defaultValue: PropTypes.string,
  title: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  children: PropTypes.arrayOf(PropTypes.element),
};
