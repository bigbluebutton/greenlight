/* eslint-disable react/jsx-props-no-spreading */

import { Form } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import React from 'react';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import useUpdateSiteSetting from '../../../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';

export default function BrandColorForm({ name, color, btnVariant }) {
  const { register, handleSubmit } = useForm();
  const updateSiteSetting = useUpdateSiteSetting(name);

  return (
    <Form onSubmit={handleSubmit(updateSiteSetting.mutate)}>
      <Form.Group className="mb-3">
        <Form.Control
          type="color"
          id={name}
          defaultValue={color}
          {...register('value')}
        />
      </Form.Group>

      <Button variant={btnVariant} type="submit">
        Submit
      </Button>
    </Form>
  );
}

BrandColorForm.propTypes = {
  name: PropTypes.string.isRequired,
  color: PropTypes.string.isRequired,
  btnVariant: PropTypes.string.isRequired,
};
