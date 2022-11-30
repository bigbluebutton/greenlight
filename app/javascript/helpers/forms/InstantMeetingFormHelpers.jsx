import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  username: yup.string().required('Please enter a username.'),
});

export const instantMeetingFormConfig = {
  mode: 'onSubmit',
  criteriaMode: 'firstError',
  defaultValues: {
    username: '',
  },
  resolver: yupResolver(validationSchema),
};

export const instantMeetingFormFields = {
  username: {
    label: 'Username',
    placeHolder: 'Enter a username',
    controlId: 'instantMeetingFormUsername',
    hookForm: {
      id: 'username',
    },
  },
};
