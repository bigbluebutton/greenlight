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
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useRoomJoinFormValidation() {
  const { t } = useTranslation();
  return useMemo(() => (yup.object({
    name: yup.string().required(t('forms.validations.room_join.name.required')),
    access_code: yup.string(),
    consent: yup.boolean().oneOf([true], ''),
  })), [t]);
}

export default function useRoomJoinForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: t('forms.room_join.fields.name.label'),
      placeHolder: t('forms.room_join.fields.name.placeholder'),
      controlId: 'joinFormName',
      hookForm: {
        id: 'name',
      },
    },
    accessCode: {
      label: t('forms.room_join.fields.access_code.label'),
      placeHolder: t('forms.room_join.fields.access_code.placeholder'),
      controlId: 'joinFormCode',
      hookForm: {
        id: 'access_code',
      },
    },
    recordingConsent: {
      label: t('forms.room_join.fields.recording_consent.label'),
      controlId: 'consentCheck',
      hookForm: {
        id: 'consent',
        validations: {
          shouldUnregister: true,
        },
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useRoomJoinFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onSubmit',
      criteriaMode: 'firstError',
      defaultValues: {
        ...{
          name: '',
          access_code: '',
        },
        ..._defaultValues,
      },
      resolver: yupResolver(validationSchema),
    },
    ..._config,
  }), [validationSchema, _defaultValues]);

  const methods = useForm(config);

  const reset = useCallback(() => methods.reset(config.defaultValues), [methods.reset, config.defaultValues]);

  return { methods, fields, reset };
}
