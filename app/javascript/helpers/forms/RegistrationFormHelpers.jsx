import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  value: yup.string(),
});

export const RegistrationFormConfig = {
  mode: 'onChange',
  defaultValues: {
    value: '',
  },
  resolver: yupResolver(validationSchema),
};

export const RegistrationFormFields = {
  value: {
    placeHolder: 'Enter a role mapping rule...',
    controlId: 'RegistrationFormvalue',
    hookForm: {
      id: 'value',
    },
  },
};
