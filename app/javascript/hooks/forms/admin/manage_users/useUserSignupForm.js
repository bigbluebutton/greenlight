import { useMemo } from 'react';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useSignUpFormValidation } from '../../users/authentication/useSignUpForm';

export default function useUserSignupForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: t('forms.admin.createUser.fields.full_name.label'),
      placeHolder: t('forms.admin.createUser.fields.full_name.placeholder'),
      controlId: 'createUserFormFullName',
      hookForm: {
        id: 'name',
      },
    },
    email: {
      label: t('forms.admin.createUser.fields.email.label'),
      placeHolder: t('forms.admin.createUser.fields.email.placeholder'),
      controlId: 'createUserFormEmail',
      hookForm: {
        id: 'email',
      },
    },
    password: {
      label: t('forms.admin.createUser.fields.password.label'),
      placeHolder: t('forms.admin.createUser.fields.password.placeholder'),
      controlId: 'createUserFormPwd',
      hookForm: {
        id: 'password',
        validations: {
          deps: ['password_confirmation'],
        },
      },
    },
    password_confirmation: {
      label: t('forms.admin.createUser.fields.password_confirmation.label'),
      placeHolder: t('forms.admin.createUser.fields.password_confirmation.placeholder'),
      controlId: 'createUserFormPwdConfirm',
      hookForm: {
        id: 'password_confirmation',
        validations: {
          deps: ['password'],
        },
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useSignUpFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      criteriaMode: 'all',
      defaultValues: {
        ...{
          name: '',
          email: '',
          password: '',
          password_confirmation: '',
        },
        ..._defaultValues,
      },
      resolver: yupResolver(validationSchema),
    },
    ..._config,
  }), [validationSchema, _defaultValues]);

  return { methods: useForm({ ...config, ..._config }), fields };
}
