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
  currentTag, allowedTags, updateMutation: useUpdateAPI,
}) {
  /* eslint-disable no-param-reassign */
  const serverTagsMap = process.env.SERVER_TAG_NAMES.split(',').reduce((map, pair) => {
    const [key, value] = pair.split(':');
    map[key] = value;
    return map;
  }, {});
  /* eslint-enable no-param-reassign */

  function getTagName(tag) {
    if (tag in serverTagsMap) {
      return serverTagsMap[tag];
    }
    return process.env.DEFAULT_TAG_NAME;
  }

  const updateAPI = useUpdateAPI();
  const dropdownTags = process.env.SERVER_TAG_NAMES.split(',').map((pair) => {
    const [tagString, tagName] = pair.split(':');
    return (allowedTags.includes(tagString) && (
      <Dropdown.Item
        key={tagString}
        value={tagName}
        onClick={() => updateAPI.mutate({ settingName: 'serverTag', settingValue: tagString })}
      >
        {tagName}
      </Dropdown.Item>
    ));
  });

  return (
    <Row>
      <SimpleSelect defaultValue={getTagName(currentTag)}>
        {[
          <Dropdown.Item
            key=""
            value={process.env.DEFAULT_TAG_NAME}
            onClick={() => updateAPI.mutate({ settingName: 'serverTag', settingValue: '' })}
          >
            {process.env.DEFAULT_TAG_NAME}
          </Dropdown.Item>,
        ].concat(dropdownTags)}
      </SimpleSelect>
    </Row>
  );
}

ServerTagRow.defaultProps = {
  currentTag: '',
};

ServerTagRow.propTypes = {
  currentTag: PropTypes.string,
  allowedTags: PropTypes.arrayOf(PropTypes.string).isRequired,
  updateMutation: PropTypes.func.isRequired,
};
