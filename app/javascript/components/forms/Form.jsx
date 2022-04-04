import React, { useCallback } from 'react';
import { FormProvider } from 'react-hook-form';
import { Form as BootStrapForm } from 'react-bootstrap';

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
