import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useEditRoleNameFormValidation() {
  return useMemo(() => (yup.object({
    name: yup.string().required('forms.validations.role_name.required'),
  })), []);
}

export default function useEditRoleNameForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: t('forms.admin.roles.fields.name.label'),
      placeHolder: t('forms.admin.roles.fields.name.placeholder'),
      controlId: 'createRoleFormName',
      hookForm: {
        id: 'name',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useEditRoleNameFormValidation();

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
