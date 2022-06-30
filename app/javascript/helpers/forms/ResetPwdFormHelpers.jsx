import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  new_password: yup.string().required('Please enter your new password.').min(8, 'Password must have at least 8 characters.'),
  password_confirmation: yup.string().oneOf([yup.ref('new_password')], 'Your passwords do not match.'),
});

export const resetPwdFormConfig = {
  mode: 'onChange',
  criteriaMode: 'firstError',
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
