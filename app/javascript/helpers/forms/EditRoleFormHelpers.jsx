import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter the role name.'),
});

export const editRoleFormConfig = {
  mode: 'onChange',
  defaultValues: {},
  resolver: yupResolver(validationSchema),
};

export const editRoleFormFields = {
  name: {
    label: 'Name',
    placeHolder: 'Enter role name',
    controlId: 'editRoleFormName',
    hookForm: {
      id: 'name',
    },
  },
};
