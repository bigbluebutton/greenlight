import * as yup from 'yup';

export const validationSchema = yup.object({
  name:
    yup.string()
      .required('Please enter a new name.')
      .max(24, 'Your new name must be within 40 characters.'),
});

export const updateUserFormFields = {
  name: {
    label: 'New Name',
    controlId: 'updateUserFormName',
    hookForm: {
      id: 'name',
    },
  },
};
