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

import Popover from 'react-bootstrap/Popover';
import React, { useEffect, useState } from 'react';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import Button from 'react-bootstrap/Button';
import PropTypes from 'prop-types';
import { HexColorPicker, HexColorInput } from 'react-colorful';
import { Stack } from 'react-bootstrap';
import tinycolor from 'tinycolor2';
import { useTranslation } from 'react-i18next';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function BrandColorPopover({
  name, btnName, btnVariant, initialColor,
}) {
  const { t } = useTranslation();
  const updatePrimaryColor = useUpdateSiteSetting('PrimaryColor');
  const updateLightColor = useUpdateSiteSetting('PrimaryColorLight');

  const [color, setColor] = useState();
  const [show, setShow] = useState(false);

  useEffect(() => {
    setColor(initialColor);
  }, [initialColor]);

  const handleSave = () => {
    setShow(false);
    if (name === 'PrimaryColor') {
      updatePrimaryColor.mutate({ value: color });
      updateLightColor.mutate({ value: tinycolor(color).lighten(45).toString() });
    } else {
      updateLightColor.mutate({ value: color });
    }
  };

  const handleChange = (inputColor) => {
    setColor(inputColor);
  };

  const handleCancel = () => {
    setShow(false);
    setColor(initialColor);
  };

  return (
    <OverlayTrigger
      trigger="click"
      placement="bottom"
      rootClose
      show={show}
      overlay={(
        <Popover className="border-0">
          <div className="color-picker rounded-3 card-shadow">
            <HexColorPicker color={color} onChange={handleChange} />
            <div className="mt-3 px-3">
              <HexColorInput className="w-100 form-control" color={color} onChange={handleChange} prefixed />
              <div className="color-preview" style={{ background: initialColor }} />
              <div className="color-preview" style={{ background: color }} />
              <Stack direction="horizontal" className="mt-2 pb-2 float-end">
                <Button variant="neutral" className="btn-sm me-2" onClick={handleCancel}> { t('cancel') } </Button>
                <Button variant="brand" className="btn-sm" onClick={handleSave}> { t('save') } </Button>
              </Stack>
            </div>
          </div>
        </Popover>
      )}
    >
      <Button className="me-4" variant={btnVariant} onClick={() => setShow(!show)}>{btnName}</Button>
    </OverlayTrigger>
  );
}

BrandColorPopover.propTypes = {
  name: PropTypes.string.isRequired,
  btnName: PropTypes.string.isRequired,
  btnVariant: PropTypes.string.isRequired,
  initialColor: PropTypes.string.isRequired,
};
