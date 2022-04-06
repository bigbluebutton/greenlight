/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useFormContext } from 'react-hook-form';
import PropTypes from 'prop-types';

export default function FormControl({ field, ...props }) {
  const { register, formState: { errors } } = useFormContext();
  const { hookForm } = field;
  const { id, validations } = hookForm;
  const error = errors[id];
  return (
    <BootStrapForm.Group controlId={field.controlId}>
      <BootStrapForm.Label>
        {field.label}
      </BootStrapForm.Label>
      <BootStrapForm.Control {...props} placeholder={field.placeHolder} isInvalid={error} {...register(id, validations)} />
      {
              error
              && (
                (error.types
                  && Object.keys(error.types).map(
                    (key) => <BootStrapForm.Control.Feedback key={key} type="invalid">{error.types[key]}</BootStrapForm.Control.Feedback>,
                  )
                )
                || <BootStrapForm.Control.Feedback type="invalid">{error.message}</BootStrapForm.Control.Feedback>
              )

          }
    </BootStrapForm.Group>
  );
}

FormControl.propTypes = {
  field: PropTypes.shape(
    {
      label: PropTypes.string.isRequired,
      placeHolder: PropTypes.string.isRequired,
      controlId: PropTypes.string.isRequired,
      hookForm: PropTypes.shape(
        {
          id: PropTypes.string.isRequired,
          validations: PropTypes.shape({
            deps: PropTypes.arrayOf(PropTypes.string),
          }),
        },
      ).isRequired,
    },
  ).isRequired,
};
