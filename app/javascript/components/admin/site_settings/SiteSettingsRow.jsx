import React from 'react';
import PropTypes from 'prop-types';
import { Stack } from 'react-bootstrap';
import useUpdateSiteSetting from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';

export default function SiteSettingsRow({
  name, title, description, value,
}) {
  const updateSiteSetting = useUpdateSiteSetting(name);

  return (
    <div>
      <Stack className="my-4" direction="horizontal">
        <Stack>
          <strong> {title} </strong>
          {description}
        </Stack>
        <div className="form-switch">
          <input
            className="form-check-input text-primary fs-5"
            type="checkbox"
            defaultChecked={value === 'true'}
            onClick={(event) => {
              updateSiteSetting.mutate({ value: event.target.checked });
            }}
          />
        </div>
      </Stack>
    </div>
  );
}

SiteSettingsRow.propTypes = {
  name: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]).isRequired,
  description: PropTypes.node.isRequired,
};
