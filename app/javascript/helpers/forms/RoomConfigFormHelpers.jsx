import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  value: yup.mixed().oneOf(['optional', 'true', 'false']),
});

export const RoomConfigFormConfig = {
  defaultValues: {
    value: 'optional',
  },
  resolver: yupResolver(validationSchema),
};

export const RoomConfigFormFields = {
  value: {
    controlId: 'RoomConfigFormValue',
    hookForm: {
      id: 'value',
    },
  },
};
