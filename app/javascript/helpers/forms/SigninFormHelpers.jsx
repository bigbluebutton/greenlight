import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  email: yup.string().required('Please enter your email.').email('Entered value does not match email format.'),
  password: yup.string().required('Please enter your password.'),
});

export const signinFormConfig = {
  defaultValues: {
    email: '',
    password: '',
  },
  resolver: yupResolver(validationSchema),
};

export const signinFormFields = {
  email: {
    label: 'Email',
    placeHolder: 'Email',
    controlId: 'signinFormEmail',
    hookForm: {
      id: 'email',
    },
  },
  password: {
    label: 'Password',
    placeHolder: 'Password',
    controlId: 'signinFormPwd',
    hookForm: {
      id: 'password',
    }
  },
}
