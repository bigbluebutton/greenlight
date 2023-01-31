import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useEditRoleLimitFormValidation() {
  return useMemo(() => (yup.object({
    value: yup.number().required('forms.validations.role.limit.required')
      .min(0, 'forms.validations.role.limit.min')
      .max(100, 'forms.validations.role.limit.max'),
  })), []);
}

export default function useEditRoleLimitForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    value: {
      label: t('forms.admin.roles.fields.value.label'),
      placeHolder: t('forms.admin.roles.fields.value.placeholder'),
      controlId: 'editRoleRoomLimit',
      hookForm: {
        id: 'value',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useEditRoleLimitFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      defaultValues: {
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
