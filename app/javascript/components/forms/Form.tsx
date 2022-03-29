import React, { ReactElement, useCallback } from 'react';
import { FormProvider, UseFormReturn, SubmitHandler, FieldValues } from 'react-hook-form';
import { Form as BootStrapForm, FormProps } from 'react-bootstrap';

interface HookFormProps<TFieldValues>{
    methods: UseFormReturn<TFieldValues>,
    submitHandler: SubmitHandler<TFieldValues>
}

type Props<T> = FormProps & HookFormProps<T>

const Form = <TFV extends FieldValues>({ methods, children, submitHandler, ...props }: Props<TFV>): ReactElement => {
    
    const onReset = useCallback(()=> methods.reset() ,[methods.reset])
    return (
        <FormProvider {...methods}>
            <BootStrapForm {...props} validated={methods.formState.isValid} onSubmit={methods.handleSubmit(submitHandler)} onReset={onReset}>
                {children}
            </BootStrapForm>
        </FormProvider>
    )
};

export default Form
