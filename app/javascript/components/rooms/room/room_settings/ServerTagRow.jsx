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
import { Row, Dropdown, } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SimpleSelect from '../../../shared_components/utilities/SimpleSelect';

export default function ServerTagRow({
  tag,
}) {
  const { t } = useTranslation();

  const serverTagsMap = (process.env.SERVER_TAGS_MAP || '').split(",").reduce((map, pair) => {
    let [key, value] = pair.split(":");
    map[key] = value;
    return map;
  }, {});

  return (
    <Row>
      <SimpleSelect defaultValue={tag}>
        {
          <Dropdown.Item key='' value=''>
          </Dropdown.Item>
        }

        {
          <Dropdown.Item
            key={Object.keys(serverTagsMap)[0]}
            value={Object.values(serverTagsMap)[0]}
          >
            {Object.values(serverTagsMap)[0]}
          </Dropdown.Item>
        }
      </SimpleSelect>
    </Row>
  );
}
ServerTagRow.defaultProps = {
  tag: '',
};

ServerTagRow.propTypes = {
  tag: PropTypes.string,
};
