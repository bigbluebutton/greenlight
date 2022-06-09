import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter the new name for the recording.'),
});

export const UpdateRecordingsFormConfig = {
  mode: 'onChange',
  defaultValues: {
    name: '',
  },
  resolver: yupResolver(validationSchema),
};

export const UpdateRecordingsFormFields = {
  name: {
    label: 'Name',
    placeHolder: 'Enter the recording name',
    controlId: 'UpdateRecordingsFormName',
    hookForm: {
      id: 'name',
    },
  },
};
