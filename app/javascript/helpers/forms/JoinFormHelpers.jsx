import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter your full name.'),
  access_code: yup.string(),
});

export const joinFormConfig = {
  mode: 'onSubmit',
  criteriaMode: 'firstError',
  defaultValues: {
    name: '',
    access_code: '',
  },
  resolver: yupResolver(validationSchema),
};

export const joinFormFields = {
  name: {
    label: 'Name',
    placeHolder: 'Enter your name',
    controlId: 'joinFormName',
    hookForm: {
      id: 'name',
    },
  },
  accessCode: {
    label: 'Access Code',
    placeHolder: 'Enter the access code',
    controlId: 'joinFormCode',
    hookForm: {
      id: 'access_code',
    },
  },
};
