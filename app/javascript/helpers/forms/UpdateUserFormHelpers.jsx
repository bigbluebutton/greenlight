import * as yup from 'yup';

export const validationSchema = yup.object({
  name:
    yup.string()
      .required('Please enter a new name.')
      .max(24, 'Your new name must be within 40 characters.'),
  email:
    yup.string()
      .required('Please enter your email.')
      .email('Entered value does not match email format.'),
});

export const updateUserFormFields = {
  name: {
    label: 'Full Name',
    controlId: 'updateUserFormName',
    hookForm: {
      id: 'name',
    },
  },
  email: {
    label: 'Email',
    controlId: 'updateUserFormEmail',
    hookForm: {
      id: 'email',
    },
  },
  language: {
    label: 'Language',
    controlId: 'updateUserLanguage',
    hookForm: {
      id: 'language',
    },
  },
  role_id: {
    label: 'Role',
    controlId: 'updateRole',
    hookForm: {
      id: 'role_id',
    },
  },
};
