import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  value: yup.string().url(),
});

export const linksFormConfig = {
  mode: 'onChange',
  defaultValues: {
    value: '',
  },
  resolver: yupResolver(validationSchema),
};

export const linksFormFields = {
  value: {
    placeHolder: 'Enter link here...',
    hookForm: {
      id: 'value',
    },
  },
};
