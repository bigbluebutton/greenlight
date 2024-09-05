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
  updateMutation: useUpdateAPI, currentTag, tagRequired, serverTags, fallbackMode, description,
}) {
  const updateAPI = useUpdateAPI();
  const { t } = useTranslation();

  function getDefaultTagName() {
    return t('room.settings.default_tag_name');
  }

  function getTagName(tag) {
    if (tag in serverTags) {
      return serverTags[tag];
    }
    return getDefaultTagName();
  }

  const dropdownTags = Object.entries(serverTags).map(([tagString, tagName]) => (
    (
      <Dropdown.Item
        key={tagString}
        value={tagName}
        onClick={() => updateAPI.mutate({ settingName: 'serverTag', settingValue: tagString })}
      >
        {tagName}
      </Dropdown.Item>
    )
  ));

  return (
    <Row>
      <h6 className="text-brand">{description}</h6>
      <Col>
        <SimpleSelect defaultValue={getTagName(currentTag)} dropUp>
          {[
            <Dropdown.Item
              key=""
              value={getDefaultTagName()}
              disabled={updateAPI.isLoading}
              onClick={() => updateAPI.mutate({ settingName: 'serverTag', settingValue: '' })}
            >
              {getDefaultTagName()}
            </Dropdown.Item>,
          ].concat(dropdownTags)}
        </SimpleSelect>
      </Col>
      {(fallbackMode !== 'desired' && fallbackMode !== 'required') && (
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
      )}
    </Row>
  );
}

ServerTagRow.defaultProps = {
  currentTag: '',
  tagRequired: false,
  fallbackMode: 'config',
};

ServerTagRow.propTypes = {
  updateMutation: PropTypes.func.isRequired,
  currentTag: PropTypes.string,
  tagRequired: PropTypes.bool,
  serverTags: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  fallbackMode: PropTypes.string,
  description: PropTypes.string.isRequired,
};
