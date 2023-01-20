import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useForgetPwdFormValidation() {
  return useMemo(() => (yup.object({
    email: yup.string().required('forms.user.forget_password.validations.email.required').email('forms.validations.email.email'),
  })), []);
}

export default function useForgetPwdForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    email: {
      label: t('forms.user.forget_password.fields.email.label'),
      placeHolder: t('forms.user.forget_password.fields.email.placeholder'),
      controlId: 'forgetPwdFormEmail',
      hookForm: {
        id: 'email',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useForgetPwdFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onSubmit',
      criteriaMode: 'firstError',
      defaultValues: {
        ...{
          email: '',
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
