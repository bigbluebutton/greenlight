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
import { Row, Dropdown } from 'react-bootstrap';
import SimpleSelect from '../../../shared_components/utilities/SimpleSelect';

export default function ServerTagRow({
  tag,
}) {
  const dropdownTags = process.env.SERVER_TAGS_MAP.split(',').map((pair) => {
    const [tagString, friendlyName] = pair.split(':');
    return (
      <Dropdown.Item key={tagString} value={friendlyName}>
        {friendlyName}
      </Dropdown.Item>
    );
  });

  return (
    <Row>
      <SimpleSelect defaultValue={tag}>
        {[<Dropdown.Item key="" value="" />].concat(dropdownTags)}
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
