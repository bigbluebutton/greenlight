import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  new_password: yup.string()
    .matches(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]).{8,}$/,
      'Password must have at least:',
    )
    .min(8, '- Eight characters.')
    .test('oneLower', '- One lowercase letter.', (pwd) => pwd.match(/[a-z]/))
    .test('oneUpper', '- One uppercase letter.', (pwd) => pwd.match(/[A-Z]/))
    .test('oneDigit', '- One digit.', (pwd) => pwd.match(/\d/))
    .test('oneSymbol', '- One symbol.', (pwd) => pwd.match(/[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]/)),
  password_confirmation: yup.string().required('').oneOf([yup.ref('new_password')], 'Your passwords do not match.'),
});

export const resetPwdFormConfig = {
  mode: 'onChange',
  criteriaMode: 'all',
  defaultValues: {
    new_password: '',
    password_confirmation: '',
    token: '',
  },
  resolver: yupResolver(validationSchema),
};

export const resetPwdFormFields = {
  new_password: {
    label: 'New Password',
    placeHolder: 'Enter your new password',
    controlId: 'resetPwdFormNewPwd',
    hookForm: {
      id: 'new_password',
      validations: {
        deps: ['password_confirmation'],
      },
    },
  },
  password_confirmation: {
    label: 'Confirm Password',
    placeHolder: 'Confirm password',
    controlId: 'resetPwdFormPwdConfirm',
    hookForm: {
      id: 'password_confirmation',
      validations: {
        deps: ['new_password'],
      },
    },
  },
};
