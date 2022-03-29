
import * as yup from "yup"
import { yupResolver } from '@hookform/resolvers/yup';
import { RegisterOptions, Resolver, UseFormProps } from "react-hook-form";

type fields = "name" | "email" | "password" | "password_confirmation"

export interface SignupFormInputs{
    name: string,
    email: string,
    password: string,
    password_confirmation: string
}

export interface SignupFormField{
    label: string,
    placeHolder: string,
    controlId: string,
    hookForm: {
        id: fields,
        validations: RegisterOptions
    }
}

export interface SignupFormFields{
    name: SignupFormField,
    email: SignupFormField,
    password: SignupFormField,
    password_confirmation: SignupFormField
}

// TODO: amir - Use Yup types.
const validationSchema: yup.AnyObjectSchema = yup.object({
    // TODO: amir - Revisit validations.
    name: yup.string().required('Please enter your full name.'),
    email: yup.string().required('Please enter your email.').email('Entered value does not match email format.'),
    password: yup.string().required('Please enter your password.').min(8,'Password must have at least 8 charachters.'),
    password_confirmation: yup.string().oneOf([yup.ref('password')], 'Your passwords do not match.')
  });

const resolver: Resolver<SignupFormInputs> = yupResolver(validationSchema)

export const signupFormConfig: UseFormProps<SignupFormInputs> = {
        mode: 'onChange',
        criteriaMode: 'all',
        defaultValues: {
          'name': '',
          'email': '',
          'password': '',
          'password_confirmation': ''
        },
        resolver
} 

export const signupFormFields: SignupFormFields = {
    name: {
        label: 'Full Name',
        placeHolder : 'Please enter your full name',
        controlId: 'signupFormFullName',
        hookForm: {
            id: 'name',
            validations: {}
        }
    },
    email: {
        label: 'Email',
        placeHolder : 'Please enter your email',
        controlId: 'signupFormEmail',
        hookForm: {
            id: 'email',
            validations: {}
        }
    },
    password: {
        label: 'Password',
        placeHolder : '********',
        controlId: 'signupFormPwd',
        hookForm: {
            id: 'password',
            validations: {
                deps: ['password_confirmation']
            }
        }
    },
    password_confirmation: {
        label: 'Password Confirmation',
        placeHolder : '********',
        controlId: 'signupFormPwdConfirm',
        hookForm: {
            id: 'password_confirmation',
            validations: {
                deps: ['password']
            }
        }
    }
}
