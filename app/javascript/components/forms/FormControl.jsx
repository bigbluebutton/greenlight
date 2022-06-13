/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useFormContext } from 'react-hook-form';
import PropTypes from 'prop-types';

export default function FormControl({
  field, control: Control, children, noLabel, ...props
}) {
  const { register, formState: { errors } } = useFormContext();
  const { hookForm } = field;
  const { id, validations } = hookForm;
  const error = errors[id];
  return (
    <BootStrapForm.Group className="mb-2" controlId={field.controlId}>
      {
        !noLabel
        && (
          <BootStrapForm.Label className="small mb-0">
            {field.label}
          </BootStrapForm.Label>
        )
      }
      <Control {...props} placeholder={field.placeHolder} isInvalid={error} {...register(id, validations)}>
        {children}
      </Control>
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

FormControl.defaultProps = {
  noLabel: false,
  control: BootStrapForm.Control,
  children: undefined,
};

FormControl.propTypes = {
  field: PropTypes.shape(
    {
      label: PropTypes.string.isRequired,
      placeHolder: PropTypes.string,
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
  noLabel: PropTypes.bool,
  control: PropTypes.shape({}),
  children: PropTypes.node,
};
