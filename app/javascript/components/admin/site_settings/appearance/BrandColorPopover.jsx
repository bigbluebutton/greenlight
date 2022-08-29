import Popover from 'react-bootstrap/Popover';
import React, { useEffect, useState } from 'react';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import Button from 'react-bootstrap/Button';
import PropTypes from 'prop-types';
import { HexColorPicker, HexColorInput } from 'react-colorful';
import { Stack } from 'react-bootstrap';
import tinycolor from 'tinycolor2';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function BrandColorPopover({
  name, btnName, btnVariant, initialColor,
}) {
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
          <div className="color-picker rounded-3 shadow-sm">
            <HexColorPicker color={color} onChange={handleChange} />
            <div className="mt-3 px-3">
              <HexColorInput className="w-100 form-control" color={color} onChange={handleChange} prefixed />
              <div className="color-preview" style={{ background: initialColor }} />
              <div className="color-preview" style={{ background: color }} />
              <Stack direction="horizontal" className="mt-2 pb-2 float-end">
                <Button variant="brand-backward" className="me-2" onClick={handleCancel}> Cancel </Button>
                <Button variant="brand" onClick={handleSave}> Save </Button>
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
