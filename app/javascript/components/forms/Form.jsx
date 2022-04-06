import React, { useCallback } from 'react';
import { FormProvider } from 'react-hook-form';
import { Form as BootStrapForm } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Form({
  methods, children, onSubmit, ...props
}) {
  const onReset = useCallback(() => methods.reset(), [methods.reset]);
  return (
    <FormProvider {...methods}>
      <BootStrapForm {...props} validated={methods.formState.isValid} onSubmit={methods.handleSubmit(onSubmit)} onReset={onReset}>
        {children}
      </BootStrapForm>
    </FormProvider>
  );
}
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
  onSubmit: PropTypes.func.isRequired,
};
