import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter a full name.').min(2, 'Name must be at least 2 characters long').max(255, 'Name must be at most 255 characters long'),
  email: yup.string().required('Please enter an email.').email('Entered value does not match email format.').min(6, 'Email must be at least 6 characters long').max(255, 'Email must be at most 5 characters long'),
  password: yup.string().max(255, 'Password must be at most 255 characters long')
    .matches(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]).{8,}$/,
      'Password must have at least:',
    )
    .min(8, '- Eight characters.')
    .test('oneLower', '- One lowercase letter.', (pwd) => pwd.match(/[a-z]/))
    .test('oneUpper', '- One uppercase letter.', (pwd) => pwd.match(/[A-Z]/))
    .test('oneDigit', '- One digit.', (pwd) => pwd.match(/\d/))
    .test('oneSymbol', '- One symbol.', (pwd) => pwd.match(/[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]/)),
  password_confirmation: yup.string().required('').oneOf([yup.ref('password')], 'The passwords do not match.'),
});

export const signupFormConfig = {
  mode: 'onChange',
  criteriaMode: 'all',
  defaultValues: {
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
  },
  resolver: yupResolver(validationSchema),
};

export const signupFormFields = {
  name: {
    label: 'Name',
    placeHolder: 'Enter your name',
    controlId: 'signupFormFullName',
    hookForm: {
      id: 'name',
    },
  },
  email: {
    label: 'Email',
    placeHolder: 'Enter your email',
    controlId: 'signupFormEmail',
    hookForm: {
      id: 'email',
    },
  },
  password: {
    label: 'Password',
    placeHolder: 'Create a password',
    controlId: 'signupFormPwd',
    hookForm: {
      id: 'password',
      validations: {
        deps: ['password_confirmation'],
      },
    },
  },
  password_confirmation: {
    label: 'Confirm Password',
    placeHolder: 'Confirm password',
    controlId: 'signupFormPwdConfirm',
    hookForm: {
      id: 'password_confirmation',
      validations: {
        deps: ['password'],
      },
    },
  },
};
