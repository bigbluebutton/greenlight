import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useLinksFormValidation() {
  return useMemo(() => (yup.object({
    value: yup.string().url('invalid_url'),
  })), []);
}

export default function useLinksForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    value: {
      placeHolder: t('forms.admin.site_settings.fields.value.placeholder'),
      hookForm: {
        id: 'value',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useLinksFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      defaultValues: {
        ...{
          value: '',
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
