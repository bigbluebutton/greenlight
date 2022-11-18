import React from 'react';
import PropTypes from 'prop-types';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useController } from 'react-hook-form';
import Select from '../../utilities/Select';

export default function FormSelect({
  children, variant, field, defaultValue,
}) {
  const { hookForm } = field;
  const { id: name, validations: rules } = hookForm;

  const {
    field: { onChange, onBlur },
    fieldState: { invalid },
  } = useController({
    name,
    rules,
    defaultValue,
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
        defaultOpt={{ title: defaultValue, value: defaultValue }}
        variant={variant}
        isValid={!invalid}
      >
        { children }
      </Select>
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
  defaultValue: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.bool]).isRequired,
};
