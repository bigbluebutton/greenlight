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

import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

const validationSchema = yup.object({
  // TODO: amir - Revisit validations.
  name: yup.string().required('Please enter your full name.'),
  access_code: yup.string(),
  consent: yup.boolean().oneOf([true], ''),
});

export const joinFormConfig = {
  mode: 'onSubmit',
  criteriaMode: 'firstError',
  defaultValues: {
    name: '',
    access_code: '',
  },
  resolver: yupResolver(validationSchema),
};

export const joinFormFields = {
  name: {
    label: 'Name',
    placeHolder: 'Enter your name',
    controlId: 'joinFormName',
    hookForm: {
      id: 'name',
    },
  },
  accessCode: {
    label: 'Access Code',
    placeHolder: 'Enter the access code',
    controlId: 'joinFormCode',
    hookForm: {
      id: 'access_code',
    },
  },
  recordingConsent: {
    label: 'I acknowledge that this session may be recorded. This may include my voice and video if enabled.',
    controlId: 'consentCheck',
    hookForm: {
      id: 'consent',
      validations: {
        shouldUnregister: true,
      },
    },
  },
};
