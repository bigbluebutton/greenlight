import React from 'react';
import PropTypes from 'prop-types';
import { Form as BootstrapForm } from 'react-bootstrap';
import FormControlGeneric from '../FormControlGeneric';

export default function FormCheckBox({
  field,
}) {
  return (
    <FormControlGeneric
      control={BootstrapForm.Check}
      field={field}
      label={field.label}
      type="checkbox"
    />
  );
}

FormCheckBox.propTypes = {
  // TODO: Amir - refactor propTypes to reduce duplication.
  field: PropTypes.shape(
    {
      label: PropTypes.string,
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
};
