import { Form, Stack } from 'react-bootstrap';
import React from 'react';
import PropTypes from 'prop-types';
import useRoles from '../../../../hooks/queries/admin/roles/useRoles';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function SettingSelect({
  settingName, defaultValue, title, description, children
}) {
  const updateSiteSetting = useUpdateSiteSetting(settingName);

  return (
    <Stack direction="horizontal" className="mb-3">
      <Stack>
        <strong> { title } </strong>
        <div className="text-muted">{ description }</div>
      </Stack>
      <div>
        <Form.Select
          value={defaultValue}
          onChange={(event) => {
            updateSiteSetting.mutate({ value: event.target.value });
          }}
        >
          { children }
        </Form.Select>
      </div>
    </Stack>
  );
}

SettingSelect.propTypes = {
  settingName: PropTypes.string.isRequired,
  defaultValue: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
};
