import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter your full name.'),
});

export const joinInstantMeetingFormConfig = {
  mode: 'onSubmit',
  criteriaMode: 'firstError',
  defaultValues: {
    name: '',
  },
  resolver: yupResolver(validationSchema),
};

export const joinInstantMeetingFormFields = {
  name: {
    label: 'Name',
    placeHolder: 'Enter your name',
    controlId: 'joinInstantMeetingFormName',
    hookForm: {
      id: 'name',
    },
  },
};
