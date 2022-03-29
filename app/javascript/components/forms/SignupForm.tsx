import React from "react";
import { Button, FormProps, Stack } from "react-bootstrap";
import FormControl from "./FormControl";
import Form from "./Form"; 
import { signupFormConfig, signupFormFields, SignupFormFields, SignupFormInputs } from "../../helpers/forms/SignupFormHelpers";
import { useForm } from "react-hook-form";
import Spinner from "../stylings/Spinner";
import { usePostUsers } from "../../hooks/mutations/users/Signup";


export const SignupForm: React.FC<FormProps> = () => {
    const methods = useForm<SignupFormInputs>(signupFormConfig)
    const { onSubmit } = usePostUsers()
    const { isSubmitting } = methods.formState
    const fields: SignupFormFields = signupFormFields
    return (
            <Form<SignupFormInputs> methods={methods} submitHandler={onSubmit}>
                <FormControl field={fields.name} type="text" />
                <FormControl field={fields.email} type="email" />
                <FormControl field={fields.password} type="password" />
                <FormControl field={fields.password_confirmation} type="password" />
                <Stack className="mt-1" gap={1}>
                    <Button variant="primary" type="submit" disabled={isSubmitting}>
                        Submit {' '}
                        { isSubmitting && <Spinner animation="grow" /> }
                    </Button>
                    <Button variant="secondary" type="reset">
                        Reset
                    </Button>
                </Stack>
            </Form>
    )
}

export default SignupForm