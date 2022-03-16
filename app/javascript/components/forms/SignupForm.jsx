import React from "react";
import { Button, Stack } from "react-bootstrap";
import { FormControl } from "./FormControl";
import Form from "./Form"; 
import { signupFormConfig, signupFormFields, signupFormOnSubmit } from "../../helpers/forms/SignupFormHelpers";
import { useForm } from "react-hook-form";
import { Spinner } from "../stylings/Spinner";


export default function SignupForm() {
    const methods = useForm(signupFormConfig)
    const { isSubmitting } = methods.formState
    const fields = signupFormFields
    // Custom validations on the run.
    fields.password_confirmation.hookForm.validations.validate.match = (value) => (methods.getValues('password') === value || 'Mismatches with password')
    return (
            <Form methods={methods} onSubmit={signupFormOnSubmit}>
                <FormControl field={fields.name} type="text" />
                <FormControl field={fields.email} type="email" />
                <FormControl field={fields.password} type="password" />
                <FormControl field={fields.password_confirmation} type="password" />
                <Stack className="mt-1" gap={1}>
                    <Button variant="primary" type="submit" disabled={isSubmitting}>
                        Submit {' '}
                        { isSubmitting && <Spinner/> }
                    </Button>
                    <Button variant="secondary" type="reset">
                        Reset
                    </Button>
                </Stack>
            </Form>
    )
}