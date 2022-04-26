import * as yup from 'yup';

const FILE_SIZE = 200000;
const SUPPORTED_FORMATS = 'image/jpeg|image/png';

export const validationSchema = yup.object().shape({
  avatar: yup.mixed()
    .test('required', 'Please choose a new image.', (value) => value && value.length)
    .test('fileSize', 'The file is too large.', (value) => value && value[0] && value[0].size <= FILE_SIZE)
    .test('type', 'Image format is not recognized.', (value) => value && value[0] && value[0].type.match(SUPPORTED_FORMATS)),
});

export const avatarFormFields = {
  avatar: {
    label: 'Upload an image',
    controlId: 'avatarFormAvatar',
    hookForm: {
      id: 'avatar',
    },
  },
};
