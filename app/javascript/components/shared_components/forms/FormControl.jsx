/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useFormContext } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControlGeneric from './FormControlGeneric';

export default function FormControl({
  field, control, children, noLabel, ...props
}) {
  const { t } = useTranslation();

  const { formState: { errors } } = useFormContext();
  const error = errors[field.hookForm.id];

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
      <FormControlGeneric {...props} field={field} control={control}>
        {children}
      </FormControlGeneric>
      {
        error
        && (
          (error.types
            && Object.keys(error.types).map(
              (key) => (
                error.types[key] && <BootStrapForm.Control.Feedback key={key} type="invalid">{t(error.types[key])}</BootStrapForm.Control.Feedback>
              ),
            )
          )
          || (error.message && <BootStrapForm.Control.Feedback type="invalid">{t(error.message)}</BootStrapForm.Control.Feedback>)
        )

      }
    </BootStrapForm.Group>
  );
}

FormControl.defaultProps = {
  noLabel: false,
  control: undefined,
  children: undefined,
};

FormControl.propTypes = {
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
  noLabel: PropTypes.bool,
  control: PropTypes.shape({}),
  children: PropTypes.node,
};
