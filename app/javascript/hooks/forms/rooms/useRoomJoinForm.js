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
