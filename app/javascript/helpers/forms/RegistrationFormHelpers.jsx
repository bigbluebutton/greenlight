import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  value: yup.array()
    .of(
      yup.object().shape(
        {
          name: yup.string().required(''),
          suffix: yup.string().required(''),
        },
      ),
    ),
});

export const RegistrationFormConfig = {
  mode: 'onChange',
  defaultValues: {
    value: [],
  },
  resolver: yupResolver(validationSchema),
};

export const RegistrationFormFields = (index) => ({
  name: {
    label: 'Role Name',
    placeHolder: 'Enter a role name...',
    controlId: `RegistrationForm.${index}.name`,
    hookForm: {
      id: `value.${index}.name`,
    },
  },
  suffix: {
    label: 'Email Suffix',
    placeHolder: 'Enter an email suffix...',
    controlId: `RegistrationForm.${index}.suffix`,
    hookForm: {
      id: `value.${index}.suffix`,
    },
  },
});
