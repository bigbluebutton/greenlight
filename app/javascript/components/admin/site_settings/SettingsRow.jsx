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
import PropTypes from 'prop-types';
import { Stack } from 'react-bootstrap';
import useUpdateSiteSetting from '../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function SettingsRow({
  name, title, description, value,
}) {
  const updateSiteSetting = useUpdateSiteSetting(name);

  return (
    <Stack direction="horizontal">
      <Stack>
        <strong> {title} </strong>
        {description}
      </Stack>
      <div className="form-switch">
        <input
          className="form-check-input fs-5"
          type="checkbox"
          checked={value === 'true'}
          onClick={(event) => {
            updateSiteSetting.mutate({ value: event.target.checked });
          }}
        />
      </div>
    </Stack>
  );
}

SettingsRow.defaultProps = {
  value: '',
};

SettingsRow.propTypes = {
  name: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  description: PropTypes.node.isRequired,
};
