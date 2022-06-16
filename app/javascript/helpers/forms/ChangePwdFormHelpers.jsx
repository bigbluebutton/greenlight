import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  old_password: yup.string().required('Please enter your current password.'),
  new_password: yup.string().required('Please enter your new password.').min(8, 'Password must have at least 8 characters.'),
  password_confirmation: yup.string().oneOf([yup.ref('new_password')], 'Your passwords do not match.'),
});

export const changePwdFormConfig = {
  mode: 'onChange',
  defaultValues: {
    old_password: '',
    new_password: '',
    password_confirmation: '',
  },
  resolver: yupResolver(validationSchema),
};

export const changePwdFormFields = {
  old_password: {
    label: 'Current Password',
    placeHolder: 'Enter your password',
    controlId: 'changePwdFormOldPwd',
    hookForm: {
      id: 'old_password',
    },
  },
  new_password: {
    label: 'New Password',
    placeHolder: 'Enter your new password',
    controlId: 'changePwdFormNewPwd',
    hookForm: {
      id: 'new_password',
      validations: {
        deps: ['password_confirmation'],
      },
    },
  },
  password_confirmation: {
    label: 'Confirm password',
    placeHolder: 'Confirm your new password',
    controlId: 'changePwdFormPwdConf',
    hookForm: {
      id: 'password_confirmation',
      validations: {
        deps: ['new_password'],
      },
    },
  },
};
