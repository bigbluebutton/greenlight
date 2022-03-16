import React, { useCallback } from "react";
import { Form, Button, Stack } from "react-bootstrap";
import { useForm } from "react-hook-form";
import { FormControl } from "./FormControl";
import { signupFormConfig, signupFormFields, signupFormOnSubmit } from "../../helpers/forms/SignupFormHelpers";


let count=0
export default function SignupForm() {
    const {
        register,
        handleSubmit,
        reset,
        watch,
        formState: {errors, isSubmitting, isValid}
    } = useForm( signupFormConfig )

    const onSubmit = signupFormOnSubmit
    const fields = signupFormFields
    fields.password_confirmation.hookForm.validations.validate.match = (value) => (watch('password') === value || 'Mismatches with password')
    const registers = {
        name: register(fields.name.hookForm.id, fields.name.hookForm.validations ),
        email: register(fields.email.hookForm.id, fields.email.hookForm.validations ),
        password: register(fields.password.hookForm.id, fields.password.hookForm.validations ),
        password_confirmation: register(fields.password_confirmation.hookForm.id, fields.password_confirmation.hookForm.validations ) 
    }
    const onReset = useCallback( ()=> reset() ,[reset])
      
    return (
        <Form autoComplete="off" noValidate validated={isValid} onSubmit={handleSubmit(onSubmit)} onReset={onReset}>
            <h1>Render: {++count}</h1>
            <FormControl error={errors[fields.name.hookForm.id]} field={fields.name} register={registers.name}
                type="text"
            />

            <FormControl error={errors[fields.email.hookForm.id]} field={fields.email} register={registers.email}
                type="email"
            />
            
            <FormControl error={errors[fields.password.hookForm.id]} field={fields.password} register={registers.password}
                type="password"
            />

            <FormControl error={errors[fields.password_confirmation.hookForm.id]} field={fields.password_confirmation} register={registers.password_confirmation}
                type="password"
            />

            <Stack className="mt-1" gap={1}>
                <Button variant="primary" type="submit" disabled={isSubmitting}>
                    Submit {' '}
                    { ( isSubmitting )  && <span className="spinner-border spinner-border-sm mr-1" />}
                </Button>
                <Button variant="secondary" type="reset">
                  Reset
                </Button>
            </Stack>

      </Form>
    )
}