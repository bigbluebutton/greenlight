
import * as yup from "yup"
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
    // TODO: amir - Revisit validations.
    name: yup.string().required('Please enter your full name.'),
    email: yup.string().required('Please enter your email.').email('Entered value does not match email format.'),
    password: yup.string().required('Please enter your password.').min(8,'Password must have at least 8 charachters.'),
    password_confirmation: yup.string().oneOf([yup.ref('password')], 'Your passwords do not match.')
  });

export const signupFormConfig = {
        mode: 'onChange',
        criteriaMode: 'all',
        defaultValues: {
          'name': '',
          'email': '',
          'password': '',
          'password_confirmation': ''
        },
        resolver: yupResolver(validationSchema)
} 

export const signupFormFields = {
    name: {
        label: 'Full Name',
        placeHolder : 'Please enter your fullll name',
        controlId: 'signupFormFullName',
        hookForm: {
            id: 'name'
        }
    },
    email: {
        label: 'Email',
        placeHolder : 'Please enter your email',
        controlId: 'signupFormEmail',
        hookForm: {
            id: 'email'
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
