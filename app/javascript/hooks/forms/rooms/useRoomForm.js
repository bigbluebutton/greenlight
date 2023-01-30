import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useRoomFormValidation() {
  return useMemo(() => (yup.object({
    name: yup.string().required('forms.validations.room.name.required').min(2, 'forms.validations.room.name.min'),
  })), []);
}

export default function useRoomForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: t('forms.room.fields.name.label'),
      placeHolder: t('forms.room.fields.name.placeholder'),
      controlId: 'createRoleFormName',
      hookForm: {
        id: 'name',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useRoomFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      defaultValues: {
        ...{
          name: '',
          user_id: '',
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
