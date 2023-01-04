import * as yup from 'yup';

export const validationSchema = yup.object({
  emails:
    yup.string()
      .required('Please enter your email.')
      .email('Entered value does not match email format.'),
});

export const createInvitationFormFields = {
  emails: {
    label: 'Emails',
    controlId: 'createInvitationFormEmail',
    hookForm: {
      id: 'emails',
    },
  },
};
