import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useSignInFormValidation() {
  return useMemo(() => (yup.object({
    email: yup.string().required('forms.validations.email.required').email('forms.validations.email.email'),
    password: yup.string().required('forms.validations.password.required'),
    extend_session: yup.bool(''),
  })), []);
}

export default function useSignInForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    email: {
      label: t('forms.user.signin.fields.email.label'),
      placeHolder: t('forms.user.signin.fields.email.placeholder'),
      controlId: 'signInFormEmail',
      hookForm: {
        id: 'email',
      },
    },
    password: {
      label: t('forms.user.signin.fields.password.label'),
      placeHolder: t('forms.user.signin.fields.password.placeholder'),
      controlId: 'signInFormPwd',
      hookForm: {
        id: 'password',
      },
    },
    extend_session: {
      label: t('forms.user.signin.fields.remember_me.label'),
      controlId: 'signInFormRememberMe',
      hookForm: {
        id: 'extend_session',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useSignInFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onSubmit',
      criteriaMode: 'firstError',
      defaultValues: {
        ...{
          email: '',
          password: '',
          extend_session: false,
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
