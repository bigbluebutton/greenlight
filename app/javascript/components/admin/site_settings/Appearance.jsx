/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { Form } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { useForm } from 'react-hook-form';
import useUpdateSiteSetting
  from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';
import useSiteSettings from '../../../hooks/queries/admin/site_settings/useSiteSettings';

export default function Appearance() {
  const { register, handleSubmit } = useForm();
  const updateSiteSetting = useUpdateSiteSetting('PrimaryColor');
  const { data: siteSettings } = useSiteSettings();

  return (
    <>
      <h6>Primary Color</h6>
      <Form onSubmit={handleSubmit(updateSiteSetting.mutate)}>
        <Form.Group className="mb-3">
          <Form.Control
            type="color"
            id="brandColor"
            defaultValue={siteSettings?.PrimaryColor}
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
