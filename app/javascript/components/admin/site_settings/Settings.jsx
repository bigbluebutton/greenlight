import React from 'react';
import { Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import useSiteSettings from '../../../hooks/queries/admin/site_settings/useSiteSettings';
import Spinner from '../../shared/stylings/Spinner';
import useUpdateSiteSetting from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';
import Form from '../../forms/Form';

export default function Settings() {
  const { isLoading, data: siteSettings } = useSiteSettings();
  const updateSiteSetting = useUpdateSiteSetting();
  const methods = useForm();

  if (isLoading) return <Spinner />;

  return (
    <div>
      <Stack direction="horizontal">
        <Stack>
          <strong> Allow Users to Share Rooms </strong>
          <p className="text-muted">
            Setting to disbaled will remove the button from the room options <br />
            dropdown, preventing users from sharing rooms
          </p>
        </Stack>
        <Form className="form-switch" methods={methods}>
          <input
            className="form-check-input text-primary fs-5"
            type="checkbox"
            defaultChecked={siteSettings.ShareRooms === 'true'}
            onClick={(event) => {
              updateSiteSetting.mutate({ settingName: 'ShareRooms', settingValue: event.target.checked });
            }}
          />
        </Form>
      </Stack>
    </div>

  );
}
