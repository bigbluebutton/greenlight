/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { Form } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { useForm } from 'react-hook-form';
import useUpdateSiteSetting
  from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';
import useSiteSettingAsync from '../../../hooks/queries/site_settings/useSiteSettingAsync';

export default function Appearance() {
  const { register, handleSubmit } = useForm();
  const updateSiteSetting = useUpdateSiteSetting('PrimaryColor');
  const { data: primaryColor } = useSiteSettingAsync('PrimaryColor');

  return (
    <>
      <h6>Primary Color</h6>
      <Form onSubmit={handleSubmit(updateSiteSetting.mutate)}>
        <Form.Group className="mb-3">
          <Form.Control
            type="color"
            id="brandColor"
            defaultValue={primaryColor}
            title="Choose your color"
            {...register('value')}
          />
        </Form.Group>

        <Button variant="brand" type="submit">
          Submit
        </Button>
      </Form>
    </>
  );
}
