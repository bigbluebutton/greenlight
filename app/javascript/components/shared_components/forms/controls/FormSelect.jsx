import React from 'react';
import PropTypes from 'prop-types';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useController } from 'react-hook-form';
import Select from '../../utilities/Select';

export default function FormSelect({
  children, variant, field,
}) {
  const { hookForm: { id: name, validations: rules } } = field;

  const {
    field: { onChange, onBlur, value },
    fieldState: { invalid, error },
  } = useController({
    name,
    rules,
  });

  return (
    <BootStrapForm.Group className="mb-2" controlId={field.controlId}>
      <BootStrapForm.Label className="small mb-0">
        {field.label}
      </BootStrapForm.Label>
      <Select
        id={field.controlId}
        onChange={onChange}
        onBlur={onBlur}
        value={value}
        variant={variant}
        isValid={!invalid}
      >
        { children }
      </Select>
      {
        error
        && (
          (error.types
            && Object.keys(error.types).map(
              (key) => (
                error.types[key] && <BootStrapForm.Control.Feedback key={key} type="invalid">{error.types[key]}</BootStrapForm.Control.Feedback>
              ),
            )
          )
          || (error.message && <BootStrapForm.Control.Feedback type="invalid">{error.message}</BootStrapForm.Control.Feedback>)
        )

      }
    </BootStrapForm.Group>
  );
}

FormSelect.defaultProps = {
  variant: undefined,
};

FormSelect.propTypes = {
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  variant: PropTypes.string,
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
