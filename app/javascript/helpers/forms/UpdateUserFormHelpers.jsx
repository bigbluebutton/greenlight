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
  lang: {
    label: 'Language',
    controlId: 'updateUserlang',
    hookForm: {
      id: 'lang',
    },
  },
  userRole: {
    label: 'User Role',
    controlId: 'updateUserRole',
    hookForm: {
      id: 'userRole',
    },
  },
};
