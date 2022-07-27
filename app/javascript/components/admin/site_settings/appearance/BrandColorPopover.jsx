import Popover from 'react-bootstrap/Popover';
import { BlockPicker } from 'react-color';
import React from 'react';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import Button from 'react-bootstrap/Button';
import PropTypes from 'prop-types';
import useUpdateSiteSetting
  from '../../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';

export default function BrandColorPopover({
  name, btnName, btnVariant, currentColor, defaultColors,
}) {
  const updateSiteSetting = useUpdateSiteSetting(name);

  const handleChangeComplete = (inputColor) => {
    updateSiteSetting.mutate({ value: inputColor.hex });
  };

  return (
    <OverlayTrigger
      trigger="click"
      placement="bottom"
      rootClose
      overlay={(
        <Popover className="brand-color-popover border-0">
          <BlockPicker
            color={currentColor}
            onChangeComplete={handleChangeComplete}
            colors={defaultColors}
            triangle="hide"
          />
        </Popover>
      )}
    >
      <Button className="me-4" variant={btnVariant}>{btnName}</Button>
    </OverlayTrigger>
  );
}

BrandColorPopover.propTypes = {
  name: PropTypes.string.isRequired,
  btnName: PropTypes.string.isRequired,
  btnVariant: PropTypes.string.isRequired,
  currentColor: PropTypes.string.isRequired,
  defaultColors: PropTypes.arrayOf(PropTypes.string).isRequired,
};
