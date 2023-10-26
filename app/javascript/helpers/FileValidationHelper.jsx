// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

const IMAGE_SUPPORTED_FORMATS = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
};

const PRESENTATION_SUPPORTED_FORMATS = {
  '.doc': 'application/msword',
  '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  '.ppt': 'application/vnd.ms-powerpoint',
  '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  '.pdf': 'application/pdf',
  '.xls': 'application/vnd.ms-excel',
  '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  '.txt': 'text/plain',
  '.rtf': 'application/rtf',
  '.odt': 'application/vnd.oasis.opendocument.text',
  '.ods': 'application/vnd.oasis.opendocument.spreadsheet',
  '.odp': 'application/vnd.oasis.opendocument.presentation',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
};

export const IMAGE_SUPPORTED_EXTENSIONS = Object.keys(IMAGE_SUPPORTED_FORMATS);
export const IMAGE_SUPPORTED_MIMES = Object.values(IMAGE_SUPPORTED_FORMATS);
export const PRESENTATION_SUPPORTED_EXTENSIONS = Object.keys(PRESENTATION_SUPPORTED_FORMATS);
export const PRESENTATION_SUPPORTED_MIMES = Object.values(PRESENTATION_SUPPORTED_FORMATS);

export const IMAGE_MAX_FILE_COEFF = 3;
export const PRESENTATION_MAX_FILE_COEFF = 30;

export const fileValidation = (file, type) => {
  const MEBIBYTE = 1024 * 1024;
  const MAX_FILE_SIZE = type === 'image' ? IMAGE_MAX_FILE_COEFF * MEBIBYTE : PRESENTATION_MAX_FILE_COEFF * MEBIBYTE;
  const SUPPORTED_MIMES = type === 'image' ? IMAGE_SUPPORTED_MIMES : PRESENTATION_SUPPORTED_MIMES;

  if (file.size > MAX_FILE_SIZE) {
    throw new Error('fileSizeTooLarge');
  } else if (!SUPPORTED_MIMES.includes(file.type)) {
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
