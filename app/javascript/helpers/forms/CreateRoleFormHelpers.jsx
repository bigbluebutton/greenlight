import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter the role name.'),
});

export const createRoleFormConfig = {
  mode: 'onChange',
  criteriaMode: 'all',
  defaultValues: {
    name: '',
  },
  resolver: yupResolver(validationSchema),
};

export const createRoleFormFields = {
  name: {
    label: 'Role Name',
    placeHolder: 'Enter a role name...',
    controlId: 'createRoleFormName',
    hookForm: {
      id: 'name',
    },
  },
};
