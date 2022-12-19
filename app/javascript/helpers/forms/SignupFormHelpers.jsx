import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('forms.user.signup.full_name.required')
    .min(2, 'forms.user.signup.full_name.min')
    .max(255, 'forms.user.signup.full_name.max'),

  email: yup.string().required('forms.user.signup.email.required').email('forms.user.signup.email.email')
    .min(6, 'forms.user.signup.email.min')
    .max(255, 'forms.user.signup.email.max'),

  password: yup.string().max(255, 'forms.user.signup.password.max')
    .matches(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]).{8,}$/,
      'forms.user.signup.password.match',
    )
    .min(8, 'forms.user.signup.password.min')
    .test('oneLower', 'forms.user.signup.password.lower', (pwd) => pwd.match(/[a-z]/))
    .test('oneUpper', 'forms.user.signup.password.upper', (pwd) => pwd.match(/[A-Z]/))
    .test('oneDigit', 'forms.user.signup.password.digit', (pwd) => pwd.match(/\d/))
    .test('oneSymbol', 'forms.user.signup.password.symbol', (pwd) => pwd.match(/[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]/)),
  password_confirmation: yup.string().required('forms.user.signup.password_confirmation.required')
    .oneOf([yup.ref('password')], 'forms.user.signup.password_confirmation.match'),
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
