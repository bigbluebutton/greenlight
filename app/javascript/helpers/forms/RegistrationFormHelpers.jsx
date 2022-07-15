import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  roles_map: yup.array()
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
    roles_map: [],
  },
  resolver: yupResolver(validationSchema),
};

export const RegistrationFormFields = (index) => ({
  name: {
    label: 'Role Name',
    placeHolder: 'Enter a role name...',
    controlId: `RegistrationForm.${index}.name`,
    hookForm: {
      id: `roles_map.${index}.name`,
    },
  },
  suffix: {
    label: 'Email Suffix',
    placeHolder: 'Enter an email suffix...',
    controlId: `RegistrationForm.${index}.suffix`,
    hookForm: {
      id: `roles_map.${index}.suffix`,
    },
  },
});
