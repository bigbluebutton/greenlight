import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter the room name.'),
});

export const createRoomFormConfig = {
  mode: 'onChange',
  criteriaMode: 'all',
  defaultValues: {
    name: '',
    user_id: undefined,
  },
  resolver: yupResolver(validationSchema),
};

export const createRoomFormFields = {
  name: {
    label: 'Room Name',
    placeHolder: 'Enter a room name...',
    controlId: 'createRoomFormName',
    hookForm: {
      id: 'name',
    },
  },
};
