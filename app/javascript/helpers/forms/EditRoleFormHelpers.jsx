import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchemaRoleName = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter the role name.'),
});

export const validationSchemaRoomLimit = yup.object({
  value: yup.number().required('Please enter the room count limit.').min(0, 'Minimum atleast 0').max(100, 'Allowed maximum is 100'),
});

export const editRoleFormConfigRoleName = {
  mode: 'onBlur',
  defaultValues: {},
  resolver: yupResolver(validationSchemaRoleName),
};

export const editRoleFormFieldsRoleName = {
  name: {
    label: 'Name',
    placeHolder: 'Enter role name',
    controlId: 'editRoleFormName',
    hookForm: {
      id: 'name',
    },
  },
};

export const editRoleFormFieldsRoomLimit = {
  value: {
    label: 'Room Limit',
    placeHolder: 'Enter room limit',
    controlId: 'editRoleRoomLimit',
    hookForm: {
      id: 'value',
    },
  },
};
