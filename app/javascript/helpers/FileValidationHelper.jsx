export const fileValidation = (file, type) => {
  const IMAGE_MAX_FILE_SIZE = 3_000_000;
  const IMAGE_SUPPORTED_FORMATS = 'image/jpeg|image/png|image/svg';

  const PRESENTATION_MAX_FILE_SIZE = 10_000_000;
  const PRESENTATION_SUPPORTED_FORMATS = [
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/pdf',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'application/rtf',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.oasis.opendocument.spreadsheet',
    'application/vnd.oasis.opendocument.presentation',
    'application/vnd'];

  const MAX_FILE_SIZE = type === 'image' ? IMAGE_MAX_FILE_SIZE : PRESENTATION_MAX_FILE_SIZE;
  const SUPPORTED_FORMATS = type === 'image' ? IMAGE_SUPPORTED_FORMATS : PRESENTATION_SUPPORTED_FORMATS;

  if (file.size > MAX_FILE_SIZE) {
    throw new Error('fileSizeTooLarge');
  } else if (!file.type.match(SUPPORTED_FORMATS)) {
    throw new Error('fileTypeNotSupported');
  }
};

export const handleError = (error, t, toast) => {
  switch (error.message) {
    case 'fileSizeTooLarge':
      toast.error(t('toast.error.file_size_too_large'));
      break;
    case 'fileTypeNotSupported':
      toast.error(t('toast.error.file_type_not_supported'));
      break;
    default:
      toast.error(t('toast.error.file_upload_error'));
  }
};
