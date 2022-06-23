import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  email: yup.string().required('Please enter the account email.').email('Entered value does not match email format.'),
});

export const forgetPwdFormConfig = {
  mode: 'onSubmit',
  criteriaMode: 'firstError',
  defaultValues: {
    email: '',
  },
  resolver: yupResolver(validationSchema),
};

export const forgetPwdFormFields = {
  email: {
    label: 'Email',
    placeHolder: 'Enter the account email',
    controlId: 'forgetPwdFormEmail',
    hookForm: {
      id: 'email',
    },
  },
};
