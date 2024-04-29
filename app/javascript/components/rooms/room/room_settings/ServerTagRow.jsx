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
import PropTypes from 'prop-types';
import {
  Row, Col, Dropdown, ButtonGroup, ToggleButton,
} from 'react-bootstrap';
import SimpleSelect from '../../../shared_components/utilities/SimpleSelect';

export default function ServerTagRow({
  updateMutation: useUpdateAPI, currentTag, tagRequired, allowedTags, description,
}) {
  const updateAPI = useUpdateAPI();
  const { t } = useTranslation();

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
      <h6 className="text-brand">{description}</h6>
      <Col>
        <SimpleSelect defaultValue={getTagName(currentTag)} dropUp>
          {[
            <Dropdown.Item
              key=""
              value={process.env.DEFAULT_TAG_NAME}
              disabled={updateAPI.isLoading}
              onClick={() => updateAPI.mutate({ settingName: 'serverTag', settingValue: '' })}
            >
              {process.env.DEFAULT_TAG_NAME}
            </Dropdown.Item>,
          ].concat(dropdownTags)}
        </SimpleSelect>
      </Col>
      <Col>
        <ButtonGroup>
          <ToggleButton
            key="desired"
            id="desired"
            type="radio"
            variant="outline-success"
            name="radio"
            checked={tagRequired === false}
            disabled={updateAPI.isLoading}
            onChange={() => {
              updateAPI.mutate({ settingName: 'serverTagRequired', settingValue: false });
            }}
          >
            {t('room.settings.server_tag_desired')}
          </ToggleButton>
          <ToggleButton
            key="required"
            id="required"
            type="radio"
            variant="outline-danger"
            name="radio"
            checked={tagRequired === true}
            disabled={updateAPI.isLoading}
            onChange={() => {
              updateAPI.mutate({ settingName: 'serverTagRequired', settingValue: true });
            }}
          >
            {t('room.settings.server_tag_required')}
          </ToggleButton>
        </ButtonGroup>
      </Col>
    </Row>
  );
}

ServerTagRow.defaultProps = {
  currentTag: '',
  tagRequired: false,
};

ServerTagRow.propTypes = {
  updateMutation: PropTypes.func.isRequired,
  currentTag: PropTypes.string,
  tagRequired: PropTypes.bool,
  allowedTags: PropTypes.arrayOf(PropTypes.string).isRequired,
  description: PropTypes.string.isRequired,
};
