/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { FormProvider } from 'react-hook-form';
import { Form as BootStrapForm } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Form({
  methods, children, onSubmit, ...props
}) {
  return (
    <FormProvider {...methods}>
      <BootStrapForm {...props} noValidate onSubmit={methods.handleSubmit(onSubmit)}>
        {children}
      </BootStrapForm>
    </FormProvider>
  );
}

Form.defaultProps = {
  onSubmit: () => { },
  onBlur: () => { },
  onChange: () => { },
};

Form.propTypes = {
  methods: PropTypes.shape(
    {
      reset: PropTypes.func.isRequired,
      handleSubmit: PropTypes.func.isRequired,
      formState: PropTypes.shape({
        isSubmitted: PropTypes.bool.isRequired,
        isSubmitting: PropTypes.bool.isRequired,
        isValid: PropTypes.bool.isRequired,
      }).isRequired,
    },
  ).isRequired,
  children: PropTypes.node.isRequired,
  onSubmit: PropTypes.func,
  onBlur: PropTypes.func,
  onChange: PropTypes.func,
};
