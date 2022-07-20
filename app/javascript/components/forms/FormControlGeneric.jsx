/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useFormContext } from 'react-hook-form';
import PropTypes from 'prop-types';

export default function FormControlGeneric({
  field, control: Control, children, fieldError, ...props
}) {
  const { register, formState: { errors } } = useFormContext();
  const { hookForm } = field;
  const { id, validations } = hookForm;
  const error = fieldError ?? errors[id];

  return (
    <Control {...props} placeholder={field.placeHolder} isInvalid={error} {...register(id, validations)}>
      {children}
    </Control>
  );
}

FormControlGeneric.defaultProps = {
  control: BootStrapForm.Control,
  children: undefined,
  fieldError: undefined,
};

FormControlGeneric.propTypes = {
  field: PropTypes.shape(
    {
      label: PropTypes.string,
      placeHolder: PropTypes.string,
      controlId: PropTypes.string,
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
  control: PropTypes.shape({}),
  children: PropTypes.node,
  fieldError: PropTypes.shape({
    types: PropTypes.objectOf(
      PropTypes.oneOfType([
        PropTypes.string,
        PropTypes.bool,
      ]),
    ),
    message: PropTypes.string,
  }),
};
