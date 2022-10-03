import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchemaRoleName = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter the role name.'),
});

const validationSchemaRoomLimit = yup.object({
  roomLimit: yup.number().required('Please enter the room count limit.').min(0, 'Minimum atleast 0').max(100, 'Allowed maximum is 100'),
});

export const editRoleFormConfigRoleName = {
  mode: 'onBlur',
  defaultValues: {},
  resolver: yupResolver(validationSchemaRoleName),
};

export const editRoleFormConfigRoomLimit = {
  mode: 'onBlur',
  defaultValues: {},
  resolver: yupResolver(validationSchemaRoomLimit),
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
  roomLimit: {
    label: 'Room Limit',
    placeHolder: 'Enter room limit',
    controlId: 'editRoleRoomLimit',
    hookForm: {
      id: 'roomLimit',
    },
  },
};
